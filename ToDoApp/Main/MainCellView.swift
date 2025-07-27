//
//  MainCellView.swift
//  ToDoApp
//
//  Created by Valery Zvonarev on 26.07.2025.
//

import SwiftUI

struct MainCellView: View {
    @State var toDoItem: ToDoItem

    var body: some View {
//        HStack(alignment: .top, spacing: 12) {
////                HStack {
//                    Image(systemName: "checkmark.circle")
//                        .foregroundStyle(.appYellow)
//                        .font(.system(size: 24, weight: .regular))
////                }
//            VStack(alignment: .leading, spacing: 6) {
//                Text("Buy milk")
//                    .font(.system(size: 16, weight: .medium))
//                    .frame(height: 22, alignment: .center)
//                Text("Every day at 10:00")
//                    .font(.system(size: 16, weight: .regular))
//                Text(Date.now, format: .dateTime)
//                    .font(.system(size: 16, weight: .regular))
//            }
//            .frame(maxWidth: .infinity, alignment: .leading)
//        }
//        .padding(.vertical, 8)
//        .listRowInsets(EdgeInsets())

            HStack(alignment: .top) {
                HStack {
                    Image(systemName: toDoItem.completed ? "checkmark.circle" : "circle")
                        .foregroundStyle(toDoItem.completed ? .appYellow : .gray)
                        .font(.system(size: 24, weight: .regular))
                }
            VStack(alignment: .leading, spacing: 6) {
                Text("ToDo #\(toDoItem.id)")
                    .font(.system(size: 16, weight: .medium))
                    .frame(height: 22, alignment: .center)
                    .foregroundColor(toDoItem.completed ? .appCompleted : .primary)
                    .overlay(
                        Group {
                            if toDoItem.completed {
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.appCompleted)
                                    .offset(y: 2)
                            }
                        }
                    )
//                Text("Every day at 10:00")
                Text(toDoItem.todo)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(toDoItem.completed ? .appCompleted : .primary)
                    .lineLimit(2)
                Text(Date.now, format: .dateTime)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.appCompleted)
            }
            .padding(.top, 3)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

//#Preview {
//    var item = ToDoItem(id: 11, todo: "Buy milk", completed: false, userId: 155)
//    MainCellView(toDoItem: item)
//}

//struct NoPaddingLabelStyle: LabelStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        HStack {
//            configuration.icon
//            configuration.title
//        }
//    }
//}


//        .padding(.vertical, 12)
//        .padding(.horizontal, 20)
//        .background(.cyan)
//        Label {
//            VStack(alignment: .leading, spacing: 6) {
//                Text("Buy milk")
//                    .font(.system(size: 16, weight: .medium))
//
//                Text("Every day at 10:00")
//                    .font(.system(size: 16, weight: .regular))
//                Text("\(Date.now)")
//                    .font(.system(size: 16, weight: .regular))
//            }
//        } icon: {
//            Image(systemName: "checkmark.circle")
//                .foregroundStyle(.appYellow)
//                .font(.system(size: 24, weight: .regular))
//        }
////        .labelStyle(NoPaddingLabelStyle())
////        .padding(.horizontal, 20)
//        .background(.cyan)
