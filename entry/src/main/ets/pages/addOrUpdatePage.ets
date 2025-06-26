import router from '@ohos.router'
import { EditViewParams, TodoItemNew } from '../viewModel/TodoListEditModel';
// 推荐使用ArkData模块（API 9+）
import { preferences } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';


@Entry
@Component
export default struct AddOrUpdatePage {
  // 明确初始化常量
  private readonly STORE_KEY: string = 'todoItems';
  private pref: preferences.Preferences | null = null;
  @State curName: string = '';
  @State curTag: string = '';
  @State curId: string = '';
  @State curDate: string = '';
  @State curTime: string = '';
  @State curCategory: string = '';

  private async loadData() {
    // 初始化数据
    try {
      this.pref = await preferences.getPreferences(getContext(this), 'todoDB');
      const items = await this.queryItems();
      console.log('初始化查询数据:', JSON.stringify(items));
    } catch (err) {
      console.error("首选项初始化失败:", (err as BusinessError).message);
    }
    // 接收参数
    const params = router.getParams() as EditViewParams;
    console.log('params', JSON.stringify(params))
    this.curId = params.id || new Date().getTime().toString();
    this.curName = params.name || '';
    this.curDate = params.date || '';
    this.curTime = params.time || '';
    this.curTag = params.tag || '';
    this.curCategory = params.category || '';
  }

  async onPageShow() {
    await this.loadData();
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

  // 保存数据方法
  private async saveItem(): Promise<void> {
    if (!this.pref || !this.curName.trim()) {
      return;
    }

    // 获取现有数据
    let itemsStr = await this.pref.get(this.STORE_KEY, '[]');
    let items: TodoItemNew[] = JSON.parse(itemsStr as string);

    // 更新或新增
    const newItem: TodoItemNew = {
      id: this.curId,
      name: this.curName,
      tag: this.curTag,
      date: this.curDate,
      time: this.curTime,
      category: this.curCategory,
      completed: false
    };
    const index = items.findIndex(item => item.id === this.curId);
    if (index >= 0) {
      items[index] = newItem; // 更新
    } else {
      items.push(newItem); // 新增
    }
    // 保存回存储
    await this.pref.put(this.STORE_KEY, JSON.stringify(items));
    await this.pref.flush();
    router.back();
  }

  @Builder
  inputRow(placeholder: string, field: keyof TodoItemNew) {
    TextInput({
      placeholder,
      text: this.getFieldValue(field)
    })
      .onChange((value: string) => {
        this.setFieldValue(field, value);
      })
      .backgroundColor(Color.White)
      .borderWidth({ bottom: 1 })
      .borderColor('#ccc')
  }

  private getFieldValue(field: keyof TodoItemNew): string {
    switch (field) {
      case 'name':
        return this.curName;
      case 'tag':
        return this.curTag;
      case 'date':
        return this.curDate;
      case 'time':
        return this.curTime;
      default:
        return '';
    }
  }

  private setFieldValue(field: keyof TodoItemNew, value: string): void {
    switch (field) {
      case 'name':
        this.curName = value;
        break;
      case 'tag':
        this.curTag = value;
        break;
      case 'date':
        this.curDate = value;
        break;
      case 'time':
        this.curTime = value;
        break;
    }
  }

  build() {
    Column() {
      Text(`${this.curCategory == 'edit' ? '编辑待办' : '新增待办'}`)
      Column({ space: 30 }) {
        // 表单组件
        this.inputRow('任务名称', 'name')
        this.inputRow('选择日期', 'date')
        this.inputRow('任务时间', 'time')
        this.inputRow('标签', 'tag')
      }.padding(20)

      // 使用Flex布局将两个按钮放在同一行
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Button('返回', { type: ButtonType.Capsule })
          .backgroundColor(Color.Transparent)// 透明背景
          .fontColor('#007DFF')
          .borderWidth(1)
          .borderColor('#007DFF')
          .width(100)
          .height(40)
          .onClick(() => router.back())

        Button('保存', { type: ButtonType.Capsule })
          .backgroundColor('#007DFF')
          .fontColor(Color.White)
          .width(100)
          .height(40)
          .onClick(() => this.saveItem())
      }
      .width('100%')
      .padding({ left: 20, right: 20 })
    }
  }
}