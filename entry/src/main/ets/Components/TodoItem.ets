import router from '@ohos.router';

@Component
export default struct TodoItem {
  @Prop currentId: string;
  @Prop name: string;
  @Prop date: string;
  @Prop time: string;
  @Prop tag: string;
  handleOpenDeleteDialog: (id: string) => void = () => {
  };

  @Builder
  IconBuilder(r: Resource, clickEvent: () => void) {
    Image(r).width(20).height(20).onClick(clickEvent);
  }

  build() {
    Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
      Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
        Text()
          .width(20)
          .height(20)
          .borderRadius(50)
          .backgroundColor('#4a63de')
        Column({ space: 10 }) {
          Text(this.name).width('100%').fontSize(20)
            .fontWeight(FontWeight.Bold)
          Text(this.date).width('100%').fontSize(16)
        }.margin({ left: 30 })
      }

      Column({ space: 10 }) {
        this.IconBuilder($r('app.media.edit_24dp_FILL0_wght400_GRAD0_opsz24'), () => {
          router.pushUrl(
            {
              url: 'pages/addOrUpdatePage',
              params: {
                id: this.currentId,
                name: this.name,
                date: this.date,
                time: this.time,
                tag: this.tag,
                category: 'edit'
              }
            }
          )
        })
        this.IconBuilder($r('app.media.delete_24dp_FILL0_wght400_GRAD0_opsz24'), () => {
          this.handleOpenDeleteDialog(this.currentId);
        })
      }
    }.padding({
      top: 10,
      bottom: 10,
      left: 20,
      right: 20
    }).borderRadius(15).shadow({
      radius: 10,
      color: '#ccc',
      type: ShadowType.COLOR,
    })
  }
}