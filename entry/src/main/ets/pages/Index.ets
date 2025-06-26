import TodoList from '../pageView/TodoList';


@Entry
@Component
struct Index {
  @State pageTitle: string = '快速入门';
  @State currentIndex: number = 0;

  build() {
    Column() {
      TodoList()
    }
  }
}