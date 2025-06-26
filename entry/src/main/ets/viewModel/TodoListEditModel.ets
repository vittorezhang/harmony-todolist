// viewModel/TodoListEditModel.ts
export interface EditViewParams {
  id: string;
  name: string;
  tag?: string;
  date?: string;
  time?: string;
  category?: string;
}

export interface TodoItemNew {
  id: string;
  name: string;
  tag: string;
  date: string;
  time: string;
  category: string;
  completed: boolean;
}

