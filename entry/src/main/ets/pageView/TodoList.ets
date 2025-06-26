import TodoItem from '../Components/TodoItem';
import router from '@ohos.router';
import { preferences } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { TodoItemNew } from '../viewModel/TodoListEditModel';
import { promptAction } from '@kit.ArkUI';

@Component
export default struct TodoList {
  // 明确初始化常量
  private readonly STORE_KEY: string = 'todoItems';
  private pref: preferences.Preferences | null = null;
  @State todoListArr: TodoItemNew[] = []; // 使用@State修饰需刷新的数组
  @State curId: string = '';
  scroller: Scroller = new Scroller();

  async aboutToAppear() {
    await this.loadData();
    this.setupDataListener(); // 初始化监听
  }

  async onPageShow() {
    await this.loadData();
  }

  onPageHide() {
    this.pref?.off('change'); // 避免内存泄漏
  }

  private async loadData() {
    try {
      if (!this.pref) {
        this.pref = await preferences.getPreferences(getContext(this), 'todoDB');
      }
      // 强制重新查询或使用缓存逻辑
      const newData = await this.queryItems();
      // 关键点：通过解构赋值触发响应式更新
      this.todoListArr = [...newData];
      console.log('数据已更新:', JSON.stringify(this.todoListArr));
    } catch (err) {
      console.error("数据加载失败:", (err as BusinessError).message);
      // 添加Toast提示（需引入@ohos.promptAction）
      promptAction.showToast({ message: '数据加载失败', duration: 2000 });
    }
  }

  private setupDataListener() {
    this.pref?.on('change', () => this.loadData());
  }

  private async queryItems(): Promise<TodoItemNew[]> {
    if (!this.pref) {
      return [];
    }
    try {
      const itemsStr = await this.pref.get(this.STORE_KEY, '[]');
      return JSON.parse(itemsStr as string) as TodoItemNew[];
    } catch (err) {
      console.error("查询失败:", (err as BusinessError).message);
      return [];
    }
  }

  // 定义删除方法，接收id参数
  private async deleteItem(id: string): Promise<void> {
    if (!this.pref) {
      return;
    }
    try {
      // 获取当前所有项目
      const itemsStr = await this.pref.get(this.STORE_KEY, '[]');
      const items: TodoItemNew[] = JSON.parse(itemsStr as string);
      // 过滤掉当前项目
      const newItems = items.filter(item => item.id !== id);
      // 保存更新后的列表
      await this.pref.put(this.STORE_KEY, JSON.stringify(newItems));
      await this.pref.flush();
    } catch (err) {
      console.error("删除失败:", (err as BusinessError).message);
    }
  }

  private showDeleteConfirm(id: string = ''): void {
    promptAction.showDialog({
      title: '确认删除',
      message: '确定要删除这个待办吗？',
      buttons: [
        { text: '取消', color: '#000000' },
        { text: '确定', color: '#FF0000' }
      ],
    }).then(result => {
      // 点击确定
      if (result.index === 1) {
        this.deleteItem(id);
      }
    });
  }

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center }) {
      Text('TodoList')
      // 列表区域（自适应高度）
      Scroll(this.scroller) {
        List() {
          ForEach(this.todoListArr, (item: TodoItemNew) => {
            TodoItem({
              currentId: item.id,
              name: item.name,
              date: item.date,
              time: item.time,
              tag: item.tag,
              // 将父组件的删除方法传递给子组件
              handleOpenDeleteDialog: this.showDeleteConfirm.bind(this)
            }).margin({
              top: 10,
              left: 20,
              right: 20,
              bottom: 10
            })
          })
        }
        .layoutWeight(1)
        .width('100%')
      }

      // 底部图片（固定位置）
      Flex({ justifyContent: FlexAlign.Center }) {
        Image($r('app.media.add_circle_24dp_13B716_FILL0_wght400_GRAD0_opsz24'))
          .width(40)
          .height(40)
          .aspectRatio(1)
          .onClick(() => {
            router.pushUrl({
              url: 'pages/addOrUpdatePage',
              params: {
                category: 'add',
              }
            })
          })
      }
      .margin({ top: 20, bottom: 20 })
    }
  }
}