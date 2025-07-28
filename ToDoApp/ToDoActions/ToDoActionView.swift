//
//  ToDoActionView.swift
//  ToDoApp
//
//  Created by Valery Zvonarev on 27.07.2025.
//

import SwiftUI

struct ToDoActionView: View {
//    @Binding var toDoItem: ToDoItem?
    @Binding var toDoEntity: ToDoEntity?
    @Environment(\.dismiss) private var dismiss
    @State private var localTodo: String = ""

    var body: some View {
        if let item = toDoEntity {
//            let toDoText = Binding(
//                get: { item.todo },
//                set: { newValue in
//                    toDoItem?.todo = newValue
//                }
//            )
            VStack(alignment: .leading) {
//                Text("ToDo \(item.id)")
                Text(item.title ?? "No title")
                    .font(.system(size: 34, weight: .bold))
                    .frame(height: 41)
//                Text("\(item.userId)")
                Text(item.date ?? "No date")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.appCompleted)
                    .frame(height: 16)
                    .padding(.bottom, 16)
//                Text("\(item.todo)")
                TextEditor(text: $localTodo)
                    .font(.system(size: 16, weight: .regular))
                    .frame(minHeight: 100)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .onAppear {
                self.localTodo = item.todo ?? "No ToDo"
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        print("New text: \(localTodo)")
                        toDoEntity?.todo = localTodo
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Назад")
                        }
                        .tint(.appYellow)
                    }
                }
            }
        }
    }
}

//#Preview {
//    var title = "Заняться спортом"
//    var text = "Составить список необходимых продуктов для ужина. Не забыть проверить, что уже есть в холодильнике."
//    var toDoEntity = ToDoEntity(entity: .init, insertInto: nil)
//    ToDoActionView(toDoEntity: toDoEntity)
////    ToDoActionView(toDoEntity: .constant(.init(id: 11, todo: text, completed: false, userId: 155)))
//}
