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
    @Published var items: [Item] = []
    @Published var listData: NetworkTodosModel
    @Published var isLoading: Bool = false
    @Published var error: Error?
    private let networkService: NetworkServiceProtocol
    private let fetchedResultsController: NSFetchedResultsController<Item>
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext, networkService: NetworkServiceProtocol = NetworkService.shared) {
        listData = NetworkTodosModel(todos: [], total: 0, skip: 0, limit: 0)
        self.networkService = networkService
        self.context = context
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)]

        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        super.init()
        fetchedResultsController.delegate = self
        performFetch()
    }

    func loadTableData() async {
//        Task {
            do {
                listData = try await networkService.fetchRequest()
            } catch {
                self.error = error
                print("Network error: \(String(describing: self.error?.localizedDescription))")
            }
//            print(initialData)
//        }
    }

    private func performFetch() {
        do {
            try fetchedResultsController.performFetch()
            items = fetchedResultsController.fetchedObjects ?? []
        } catch {
            print("Failed to fetch items: \(error)")
        }
    }

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
        items = controller.fetchedObjects as? [Item] ?? []
    }
}


//    @Environment(\.managedObjectContext) private var viewContext
//
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
//        animation: .default)
//    @Published var items: FetchedResults<Item>
