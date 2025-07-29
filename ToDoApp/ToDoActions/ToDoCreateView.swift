//
//  ToDoCreateView.swift
//  ToDoApp
//
//  Created by Valery Zvonarev on 28.07.2025.
//

import SwiftUI

struct ToDoCreateView: View {
    @Binding var createItem: Bool
    @StateObject var viewModel: MainViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var localTodo: String = "Текст todo"
    @State private var localTitle: String = "Название todo"
    @State private var localDate: String = ""
    @State private var showDatePicker: Bool = false
    @State private var selectedDate: Date = Date()

    var body: some View {
        VStack(alignment: .leading) {
            CustomTextEditor(text: $localTitle, fontSize: 34, isBold: true)
                .frame(maxHeight: 41)
                .cornerRadius(8)
//            Text(viewModel.dateFormatter(date: selectedDate))
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
//                        text = viewModel.formatDate(selectedDate)
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
            self.localDate = viewModel.dateFormatter(date: Date())
        }
        .onChange(of: selectedDate) { newDate in
            localDate = viewModel.dateFormatter(date: newDate)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    print("New text: \(localTodo)")
//                    viewModel.saveToDoEntity()
                    viewModel.addItem(title: localTitle, todo: localTodo, date: localDate)
                    createItem = false
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

//#Preview {
//    ToDoCreateView()
//}
