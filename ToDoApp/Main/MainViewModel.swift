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
    @Published var shareItems: [Any] = []
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore: Bool = false
    private let networkService: NetworkServiceProtocol
    private let fetchedResultsController: NSFetchedResultsController<ToDoEntity>
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext, networkService: NetworkServiceProtocol = NetworkService.shared) {
        listData = NetworkTodosModel(todos: [], total: 0, skip: 0, limit: 0)
        self.networkService = networkService
        self.context = context

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
            await loadTableData()
            saveTodoItemToCoreData(listData.todos, context: context)
            hasLaunchedBefore = true
        }
        performFetch()
    }


    func saveTodoItemToCoreData(_ todoItems: [ToDoItem], context: NSManagedObjectContext) {
        self.isLoading = true
        defer {
            Task { @MainActor in
                self.isLoading = false
            }
        }
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
                newItem.date = self.dateFormatter(date: Date())
            }
            self.saveToDoEntity()
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
        Task {
            do {
                try context.save()
            } catch {
                print("Ошибка сохранения CoreData: \(error.localizedDescription)")
            }
        }
    }

    func toggleItem(item: ToDoEntity) {
        guard let index = items.firstIndex(where: {$0.id == item.id}) else {
            print("Error in toggleItem function")
            return
        }
        self.items[index].completed.toggle()
        saveToDoEntity()
    }


    func addItem(title: String, todo: String, date: String) {
        withAnimation {
            let newToDoEntity = ToDoEntity(context: context)
            newToDoEntity.title = title
            newToDoEntity.todo = todo
            newToDoEntity.date = date
            newToDoEntity.completed = false
            if let lastId = items.last?.id {
                newToDoEntity.id = lastId + 1
            } else {
                newToDoEntity.id = 1
            }
            saveToDoEntity()
        }
    }


    func shareItem(item: ToDoEntity) {
        shareItems = [
            item.title ?? "Default title",
            item.todo ?? "Default todo",
            item.date ?? "Default date"
        ]
    }

    func deleteItem(item: ToDoEntity) {
        Task {
            context.delete(item)
            saveToDoEntity()
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
        return formatter.string(from: date)
    }


}

extension MainViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        items = controller.fetchedObjects as? [ToDoEntity] ?? []
    }
}


//private func coreDataSetup() async {
//    //        await setLoading(true)
//    //        defer {
//    //            Task { @MainActor in
//    //                self.isLoading = false
//    //            }
//    //        }
//    if !hasLaunchedBefore {
//        //            print("1. in coreDataSetup() - hasLaunchedBefore: \(hasLaunchedBefore)")
//        await loadTableData()
//        saveTodoItemToCoreData(listData.todos, context: context)
//        hasLaunchedBefore = true
//        //            print("2. in coreDataSetup() - hasLaunchedBefore: \(hasLaunchedBefore)")
//    }
//    //        print("3. in coreDataSetup() net skipped - hasLaunchedBefore: \(hasLaunchedBefore)")
//    //        clearCoreDataStorage(context: context)
//    performFetch()
//    //        hasLaunchedBefore = false
//}

//    private func setLoading(_ value: Bool) async {
//        await MainActor.run {
//            self.isLoading = value
//        }
//    }

// временный метод - полная очистка хранилища
//func clearCoreDataStorage(context: NSManagedObjectContext) {
//    let entities = context.persistentStoreCoordinator?.managedObjectModel.entities
//
//    entities?.forEach { entity in
//        guard let entityName = entity.name else { return }
//
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
//        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
//
//        do {
//            try context.execute(deleteRequest)
//            try context.save() // Сохраняем изменения
//        } catch {
//            print("Ошибка при удалении данных: \(error.localizedDescription)")
//        }
//    }
//}

//    private let fetchedResultsController: NSFetchedResultsController<Item>
//        let request: NSFetchRequest<Item> = Item.fetchRequest()
//        request.sortDescriptors = [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)]

//    func editItem(item: ToDoItem) {
//        print("edit item \(item.id)")
//
//    }
//    func toggleItem(item: ToDoItem) {
//        guard let index = listData.todos.firstIndex(where: {$0.id == item.id}) else {
//            print("left toggleItem function")
//            return
//        }
//        self.listData.todos[index].completed.toggle()
//    }
//    @Environment(\.managedObjectContext) private var viewContext
//
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
//        animation: .default)
//    @Published var items: FetchedResults<Item>
//    func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            offsets.map { items[$0] }.forEach(context.delete)
//
//            do {
//                try context.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }

//    let itemFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "dd/MM/yyyy"
//        formatter.locale = Locale(identifier: "ru_RU")
////        formatter.dateStyle = .short
////        formatter.timeStyle = .none
//        return formatter
//    }()
