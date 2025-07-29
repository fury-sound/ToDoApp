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
    @Published var shareItems: [Any] = [] // ["Default title", "Default content"]
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
//        hasLaunchedBefore = false
        if !hasLaunchedBefore {
            print("1. in coreDataSetup() - hasLaunchedBefore: \(hasLaunchedBefore)")
            await loadTableData()
            saveTodoItemToCoreData(listData.todos, context: context)
            hasLaunchedBefore = true
            print("2. in coreDataSetup() - hasLaunchedBefore: \(hasLaunchedBefore)")
        }
        print("3. in coreDataSetup() net skipped - hasLaunchedBefore: \(hasLaunchedBefore)")
//        clearCoreDataStorage(context: context)
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
            newItem.date = dateFormatter(date: Date())
//            newItem.date = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        }
        saveToDoEntity()
    }

// временный метод - полная очистка хранилища
    func clearCoreDataStorage(context: NSManagedObjectContext) {
        let entities = context.persistentStoreCoordinator?.managedObjectModel.entities

        entities?.forEach { entity in
            guard let entityName = entity.name else { return }

            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

            do {
                try context.execute(deleteRequest)
                try context.save() // Сохраняем изменения
            } catch {
                print("Ошибка при удалении данных: \(error.localizedDescription)")
            }
        }
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

    func saveToDoEntity() {
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

//    func addItem() {
    func addItem(title: String, todo: String, date: String) {
        withAnimation {
            print("in add item")
//            let newItem = Item(context: context)
//            newItem.timestamp = Date()
            let newToDoEntity = ToDoEntity(context: context)
            newToDoEntity.title = title
            newToDoEntity.todo = todo
            newToDoEntity.date = date
            newToDoEntity.completed = false
            newToDoEntity.id = items[items.count - 1].id + 1
            saveToDoEntity()

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

    func shareItem(item: ToDoEntity) {
//    func shareItem(item: [Any]) {
        print("share item \(item.id)")
        shareItems = [
            item.title ?? "Default title",
            item.todo ?? "Default todo",
            item.date ?? "Default date"
        ]
//        print("share item \(item)")

    }

    func deleteItem(item: ToDoEntity) {
        print("delete item \(item.id)")
        context.delete(item)
        saveToDoEntity()
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

    func taskWordCount(for count: Int) -> String {
        let remainder10 = count % 10
        let remainder100 = count % 100

        if remainder100 >= 11 && remainder100 <= 14 {
            return "задач"
        }

        switch remainder10 {
            case 1:
                return "задача"
            case 2, 3, 4:
                return "задачи"
            default:
                return "задач"
        }
    }

    func dateFormatter(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
//        formatter.dateStyle = .short
//        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

//    let itemFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "dd/MM/yyyy"
//        formatter.locale = Locale(identifier: "ru_RU")
////        formatter.dateStyle = .short
////        formatter.timeStyle = .none
//        return formatter
//    }()

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
