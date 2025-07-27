//
//  MainView.swift
//  ToDoApp
//
//  Created by Valery Zvonarev on 26.07.2025.
//

import SwiftUI
import CoreData

struct MainView: View {
    //    private let networkService: NetworkServiceProtocol
    //    @State internal var initialData: NetworkTodosModel
    //    @State internal var initialData: [ToDoModel] = []
    //    @State internal var firstEntry = true

    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: MainViewModel //<PersistenceController>
    @State private var searchQuery = ""

    init() {
        let context = PersistenceController.shared.container.viewContext
        _viewModel = StateObject(wrappedValue: MainViewModel(context: context))
    }

    var body: some View {
        VStack {
            Text("Задачи")
                .font(.system(size: 34, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
            SearchBarView(text: $searchQuery)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack {
                    //                    ForEach(viewModel.items) { item in
                    ForEach(viewModel.listData.todos) { item in
                        NavigationLink(destination: {
                            //                            Text("Item at \(item.timestamp!, formatter: viewModel.itemFormatter)")
                            Text("Item: \(item.todo)")
                        }) {
                            MainCellView(toDoItem: item)
                        }
                        .frame(maxWidth: .infinity)
                        .buttonStyle(PlainButtonStyle())
                        .contentShape(Rectangle())
                        .background(Color.white)
                        Divider()
                    }
                }
            }
//            .navigationTitle("Задачи")
//            .navigationBarBackButtonHidden(true)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Text("Добавить операцию")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color(.appWhite))
            }
        }
        .padding(.horizontal, 20)
        .task {
            await viewModel.loadTableData()
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
        ZStack {
            Text("\(viewModel.listData.total) задач")
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(.appWhite)
                .frame(height: 13)
                .padding(.vertical, 20.5)
//                .padding(.bottom, 15.5)
            HStack {
                Spacer()
                Button(action: {
                    viewModel.addItem()
                }) {
                    Image(systemName: "square.and.pencil")
                        .frame(height: 28)
                        .foregroundStyle(.appYellow)
                        .font(.system(size: 22, weight: .regular))
                        .padding(.trailing, 22)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 50) //, alignment: .trailing)
        .background(.appGray)
//        .opacity(0.5)
//        .blur(radius: 50, opaque: false)
    }
}

#Preview {
    MainView()
}



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
