//
//  MainCellView.swift
//  ToDoApp
//
//  Created by Valery Zvonarev on 26.07.2025.
//

import SwiftUI

struct MainCellView: View {
    let toDoItem: ToDoEntity
//    let isSelected: Bool
    let isPressed: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(isPressed ? Color.appGray : Color.appBlack)
//                .fill(.black)

            HStack(alignment: .top) {
                HStack {
                    Image(systemName: toDoItem.completed ? "checkmark.circle" : "circle")
                        .foregroundStyle(toDoItem.completed ? .appYellow : .gray)
                        .font(.system(size: 24, weight: .regular))
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text(toDoItem.title ?? "No name")
                        .font(.system(size: 16, weight: .medium))
                        .frame(height: 22, alignment: .center)
                        .foregroundStyle(toDoItem.completed ? .appCompleted : .appWhite)
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
                    Text(toDoItem.todo ?? "No todo")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(toDoItem.completed ? .appCompleted : .appWhite)
                        .lineLimit(2)
                    Text(toDoItem.date ?? "No date")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(.appCompleted)
                }
                .padding(.top, 3)
            }
            .padding(6)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity) //, alignment: .topLeading)
        .padding(.vertical, 2)
//        .colorScheme(.dark)
        //        .background(Color.appBlack)
//        .background(isSelected ? Color.appGray : Color.appBlack)
        //        .background(isSelected ? Color.red : Color.appBlack)
//        .cornerRadius(8)
    }
}

//#Preview {
//    var item = ToDoItem(id: 11, todo: "Buy milk", completed: false, userId: 155)
//    MainCellView(toDoItem: item)
//}


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
