//
//  ToDoActionView.swift
//  ToDoApp
//
//  Created by Valery Zvonarev on 27.07.2025.
//

import SwiftUI

struct ToDoActionView: View {
    @Binding var selectedItem: ToDoEntity?
    @Binding var editItem: Bool
    @StateObject var viewModel: MainViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var localTodo: String = ""
    @State private var localTitle: String = ""
    @State private var localDate: String = ""
    @State private var showDatePicker: Bool = false
    @State private var selectedDate: Date = Date()

    var body: some View {
        if let item = selectedItem {
            VStack(alignment: .leading) {
                CustomTextEditor(text: $localTitle, fontSize: 34, isBold: true)
                    .frame(maxHeight: 41)
                    .cornerRadius(8)
                Text(localDate)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.appWhite)
                    .frame(height: 16)
                    .padding(.bottom, 16)
                    .onTapGesture {
                        withAnimation {
                            showDatePicker.toggle()
                        }
                    }
                CustomTextEditor(text: $localTodo, fontSize: 16, isBold: false)
                    .frame(minHeight: 100)
                    .cornerRadius(8)
                if showDatePicker {
                    VStack {
                        DatePicker("Выберите дату",
                                   selection: $selectedDate,
                                   displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .padding()
                        .background(Color.appBlack)
                        .foregroundStyle(.appWhite)
                        .transition(.opacity)
                        .colorScheme(.dark)
                        Button("Готово") {
                            showDatePicker = false
                        }
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.appBlack)
            .onAppear {
                self.localTodo = item.todo ?? "No ToDo"
                self.localTitle = item.title ?? "No title"
                self.localDate = item.date ?? "No title"
            }
            .onChange(of: selectedDate) { newDate in
                localDate = viewModel.dateFormatter(date: newDate)
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        print("New text: \(localTodo)")
                        selectedItem?.todo = localTodo
                        selectedItem?.title = localTitle
                        selectedItem?.date = localDate
                        viewModel.saveToDoEntity()
                        editItem = false
                        selectedItem = nil
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
//    // 1. Создаём временный контекст Core Data для превью
//    let context = PersistenceController.preview.container.viewContext
//
//    // 2. Создаём тестовый объект
//    let toDoEntity = ToDoEntity(context: context)
//    toDoEntity.id = 1
//    toDoEntity.title = "Test Task"
//    toDoEntity.todo = "Test Description"
//    toDoEntity.completed = false
//    toDoEntity.date = "2023-01-01"
//
//    // 3. Подготавливаем State-переменные
//    @State var editItem: Bool = true
//    @State var selectedItem: ToDoEntity? = toDoEntity
//
//    // 4. Создаём ViewModel (если требуется)
//    let viewModel = MainViewModel()
//
//    // 5. Возвращаем вью с правильными параметрами
//    return ToDoActionView(
//        selectedItem: $selectedItem, // Передаём Binding
//        editItem: $editItem,
//        viewModel: viewModel
//    )
//    .environment(\.managedObjectContext, context)
//    @State var editItem: Bool = true
//    var viewModel: MainViewModel
//    var toDoEntity = ToDoEntity()
//    ToDoActionView(selectedItem: toDoEntity, editItem: $editItem, viewModel: viewModel)
//    ToDoActionView(toDoEntity: toDoEntity)
//    ToDoActionView(toDoEntity: .constant(.init(id: 11, todo: text, completed: false, userId: 155)))
//}
