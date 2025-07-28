//
//  MainViewModel.swift
//  ToDoApp
//
//  Created by Valery Zvonarev on 26.07.2025.
//

import SwiftUI
import CoreData

@MainActor
final class MainViewModel: NSObject, ObservableObject {
    @Published var items: [ToDoEntity] = []
    @Published var listData: NetworkTodosModel
    @Published var isLoading: Bool = false
    @Published var error: Error?
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore: Bool = false
    private let networkService: NetworkServiceProtocol
//    private let fetchedResultsController: NSFetchedResultsController<Item>
    private let fetchedResultsController: NSFetchedResultsController<ToDoEntity>
    private let context: NSManagedObjectContext
//    private var firstLaunch: Bool = true

    init(context: NSManagedObjectContext, networkService: NetworkServiceProtocol = NetworkService.shared) {
        listData = NetworkTodosModel(todos: [], total: 0, skip: 0, limit: 0)
        self.networkService = networkService
        self.context = context
//        let request: NSFetchRequest<Item> = Item.fetchRequest()
//        request.sortDescriptors = [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)]
        let request: NSFetchRequest<ToDoEntity> = ToDoEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ToDoEntity.id, ascending: true)]

        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        super.init()
        fetchedResultsController.delegate = self
        Task {
            await coreDataSetup()
        }
    }

    private func coreDataSetup() async {
        if !hasLaunchedBefore {
            print("1. in coreDataSetup() - hasLaunchedBefore: \(hasLaunchedBefore)")
            await loadTableData()
            saveTodoItemToCoreData(listData.todos, context: context)
            hasLaunchedBefore = true
            print("2. in coreDataSetup() - hasLaunchedBefore: \(hasLaunchedBefore)")
        }
        print("3. in coreDataSetup() net skipped - hasLaunchedBefore: \(hasLaunchedBefore)")
        performFetch()
    }


    func saveTodoItemToCoreData(_ todoItems: [ToDoItem], context: NSManagedObjectContext) {

        for item in todoItems {
            let fetchRequest: NSFetchRequest<ToDoEntity> = ToDoEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %d", item.id)
            if let existing = try? context.fetch(fetchRequest), !existing.isEmpty {
                continue
            }
            let newItem = ToDoEntity(context: context)
            newItem.id = Int32(item.id)
            newItem.title = "ToDo #\(item.id)"
            newItem.todo = item.todo
            newItem.completed = item.completed
            newItem.date = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none)
        }
        saveToDoEntity()
    }

    func loadTableData() async {
            do {
                listData = try await networkService.fetchRequest()
            } catch {
                self.error = error
                print("Network error: \(String(describing: self.error?.localizedDescription))")
            }
    }

    private func performFetch() {
        do {
            try fetchedResultsController.performFetch()
            items = fetchedResultsController.fetchedObjects ?? []
        } catch {
            print("Failed to fetch items: \(error)")
        }
    }

    private func saveToDoEntity() {
        do {
            try context.save()
        } catch {
            print("Ошибка сохранения CoreData: \(error.localizedDescription)")
        }
    }

    func toggleItem(item: ToDoEntity) {
        //        print("toggle item \(item.id)")
        guard let index = items.firstIndex(where: {$0.id == item.id}) else {
            print("left toggleItem function")
            return
        }
        self.items[index].completed.toggle()
        saveToDoEntity()
    }

    //    func toggleItem(item: ToDoItem) {
    //        guard let index = listData.todos.firstIndex(where: {$0.id == item.id}) else {
    //            print("left toggleItem function")
    //            return
    //        }
    //        self.listData.todos[index].completed.toggle()
    //    }

    func addItem() {
        withAnimation {
            print("in add item")
            let newItem = Item(context: context)
            newItem.timestamp = Date()

//            do {
//                try context.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
        }
    }



    func editItem(item: ToDoItem) {
        print("edit item \(item.id)")

    }

    func shareItem(item: ToDoItem) {
        print("share item \(item.id)")

    }

    func deleteItem(item: ToDoItem) {
        print("delete item \(item.id)")
    }

    func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(context.delete)

            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }


    let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()

}

extension MainViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        items = controller.fetchedObjects as? [ToDoEntity] ?? []
//        items = controller.fetchedObjects as? [Item] ?? []
    }
}


//    @Environment(\.managedObjectContext) private var viewContext
//
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
//        animation: .default)
//    @Published var items: FetchedResults<Item>
