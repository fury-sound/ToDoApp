//
//  MainView.swift
//  ToDoApp
//
//  Created by Valery Zvonarev on 26.07.2025.
//

import SwiftUI
import CoreData

struct MainView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: MainViewModel //<PersistenceController>
    @State private var searchQuery = ""
//    @State private var selectedItem: ToDoItem?
    @State private var selectedItem: ToDoEntity?
    @State private var editItem: Bool = false

    init() {
        let context = PersistenceController.shared.container.viewContext
        _viewModel = StateObject(wrappedValue: MainViewModel(context: context))
    }

    var body: some View {
        NavigationView {
            VStack {
                Text("Задачи")
                    .font(.system(size: 34, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                SearchBarView(text: $searchQuery)
                    .padding(.bottom, 16)
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack {
//                        ForEach(Array(viewModel.listData.todos.enumerated()), id: \.element.id) { index, item in
                        ForEach(viewModel.items, id: \.id) { item in
                            Button {
                                viewModel.toggleItem(item: item)
                            } label: {
//                                MainCellView(toDoItem: $viewModel.listData.todos[index])
                                MainCellView(toDoEntity: item)
                            }
                            .frame(maxWidth: .infinity)
                            .buttonStyle(PlainButtonStyle())
                            .contentShape(Rectangle())
                            .contextMenu {
                                Button {
                                    editItem = true
                                    selectedItem = item
//                                    print("in edit, editItem = \(editItem)")
                                } label: {
                                    Label("Редактировать", systemImage: "square.and.pencil")
                                }
                            }
                            Divider()
                        }
                    }
                    NavigationLink(
//                        destination: ToDoActionView(toDoItem: $selectedItem),
                        destination: ToDoActionView(toDoEntity: $selectedItem),
                        isActive: $editItem,
                        label: { EmptyView() }
                    )
                    .hidden()
                }
//                .task {
//                    await viewModel.loadTableData()
//                }
            }
            .padding(.horizontal, 20)
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}


#Preview {
    MainView()
}

//struct MainViewWorking: View {
//    @Environment(\.managedObjectContext) private var viewContext
//    @StateObject private var viewModel: MainViewModel //<PersistenceController>
//    @State private var searchQuery = ""
//    @State private var selectedItem: ToDoItem?
//    @State private var editItem: Bool = false
//
//    init() {
//        let context = PersistenceController.shared.container.viewContext
//        _viewModel = StateObject(wrappedValue: MainViewModel(context: context))
//    }
//
//    var body: some View {
//        VStack {
//            Text("Задачи")
//                .font(.system(size: 34, weight: .bold))
//                .frame(maxWidth: .infinity, alignment: .leading)
//            SearchBarView(text: $searchQuery)
//        }
//        .padding(.horizontal, 20)
//        .padding(.bottom, 16)
//        NavigationView {
//            ScrollView(.vertical, showsIndicators: false) {
//                LazyVStack {
//                    ForEach(Array(viewModel.listData.todos.enumerated()), id: \.element.id) { index, item in
//                            Button {
//                                viewModel.toggleItem(item: item)
//                            } label: {
//                                //                            MainCellView(toDoItem: item)
//                                MainCellView(toDoItem: $viewModel.listData.todos[index])
//                            }
//                            .frame(maxWidth: .infinity)
//                            .buttonStyle(PlainButtonStyle())
//                            .contentShape(Rectangle())
//                            .background(Color.white)
//                            .contextMenu {
//                                Button {
////                                    NavigationLink(destination: TestPageView())
//                                    editItem = true
//                                    print("in edit, editItem = \(editItem)")
////                                    selectedItem = item
//                                } label: {
//                                    Label("Редактировать", systemImage: "square.and.pencil")
//                                }
//                                Button {
//                                    viewModel.shareItem(item: item)
//                                } label: {
//                                    Label("Поделиться", systemImage: "square.and.arrow.up")
//                                }
//                                Button(role: .destructive) {
//                                    viewModel.deleteItem(item: item)
//                                } label: {
//                                    Label("Удалить", systemImage: "trash")
//                                }
//                            }
//                            Divider()
//                    }
//                }
//            }
//
//        }
//        .padding(.horizontal, 20)
//        .task {
//            await viewModel.loadTableData()
//        }
//        .overlay {
//            if viewModel.isLoading {
//                ProgressView()
//            }
//        }
//        ZStack {
//            Text("\(viewModel.listData.total) задач")
//                .font(.system(size: 11, weight: .regular))
//                .foregroundColor(.appWhite)
//                .frame(height: 13)
//                .padding(.vertical, 20.5)
//            HStack {
//                Spacer()
//                Button(action: {
//                    viewModel.addItem()
//                }) {
//                    Image(systemName: "square.and.pencil")
//                        .frame(height: 28)
//                        .foregroundStyle(.appYellow)
//                        .font(.system(size: 22, weight: .regular))
//                        .padding(.trailing, 22)
//                }
//            }
//        }
//        .frame(maxWidth: .infinity, maxHeight: 50)
//        .background(.appGray)
//    }
//}


//if let selectedItem = selectedItem {
    //            ToDoActionView(toDoItem: Binding(
    //                get: { selectedItem },
    //                set: { newValue in
    //                    viewModel.editItem(item: newValue)
    //                }
    //            ))
    //            .frame(width: 300)
    //            .transition(.move(edge: .trailing))
    //        }
    //            .animation(.default, value: selectedItem)

//#Preview {
//    MainView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//}

//        .onAppear {
//            Task {
//                do {
//                    initialData = try await networkService.fetchRequest()
//                } catch {
//                    print("Network error: \(error.localizedDescription)")
//                }
//                print(initialData)
//            }
//        }


//        NavigationView {
//            List {
//                ForEach(viewModel.items) { item in
//                    ZStack {
//                        NavigationLink(destination: {
//                            Text("Item at \(item.timestamp!, formatter: viewModel.itemFormatter)")
//                        }) {}.opacity(0)
//                            MainCellView()
//                        }
//                    }
//                    .listRowInsets(EdgeInsets())
//                    .listRowSeparatorTint(.gray)
//
////                    NavigationLink {
////                        Text("Item at \(item.timestamp!, formatter: viewModel.itemFormatter)")
////                    } label: {
////                        MainCellView()
//////                                .frame(maxWidth: .infinity, alignment: .leading)
////
//////                        Text(item.timestamp!, formatter: viewModel.itemFormatter)
////                    }
//                }
////                .onDelete(perform: viewModel.deleteItems)
//            }
//            .listStyle(.plain)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    EditButton()
//                }
//                ToolbarItem {
//                    Button(action: viewModel.addItem) {
//                        Label("Add Item", systemImage: "plus")
//                    }
//                }
//            }
//        }

//
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
//        animation: .default)
//    private var items: FetchedResults<Item>
