//
//  MainViewModelTests.swift
//  ToDoAppTests
//
//  Created by Valery Zvonarev on 29.07.2025.
//

import XCTest
import CoreData
@testable import ToDoApp

final class DelayedMockNetworkService: NetworkServiceProtocol {
    func fetchRequest() async throws -> NetworkTodosModel {
        // Искусственная задержка 0.5 секунды
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return NetworkTodosModel(todos: [
            ToDoItem(id: 1, todo: "Test", completed: false, userId: 1)
        ], total: 1, skip: 0, limit: 1)
    }
}

@MainActor
final class MainViewModelTests: XCTestCase {
    var viewModel: MainViewModel!
    var mockContext: NSManagedObjectContext!
    var mockNetworkService: NetworkServiceProtocol = MockNetworkService()

    override func setUp() {
        super.setUp()
        let container = NSPersistentContainer(name: "ToDoApp")
        let description = NSPersistentStoreDescription()
        description.url = URL(fileURLWithPath: "/dev/null")
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]

        let expectation = self.expectation(description: "Load persistence stores")
        container.loadPersistentStores { _, error in
            XCTAssertNil(error, "Failed to load persistent stores: \(error?.localizedDescription ?? "")")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
        mockContext = container.viewContext
        XCTAssertNotNil(mockContext, "Context should not be nil")
        viewModel = MainViewModel(
            context: mockContext,
            networkService: mockNetworkService
        )
    }

    // MARK: Тест первого запуска
    func testFirstLaunchInitialization() {
        UserDefaults.standard.set(false, forKey: "hasLaunchedBefore")
        let firstLaunchVM = MainViewModel(context: mockContext, networkService: mockNetworkService)
        let expectation = XCTestExpectation(description: "Wait for initialization")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertTrue(firstLaunchVM.hasLaunchedBefore)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }

    // MARK: Загрузка списка todo из сети
    func testLoadTableData() async {
        await viewModel.loadTableData()
        XCTAssertEqual(viewModel.listData.todos.count, 2)
        XCTAssertNil(viewModel.error)
    }

//    // MARK: Состояние загрузки
    func testLoadingState() async {
        // Проверяем начальное состояние
        XCTAssertFalse(viewModel.isLoading, "Initially should not be loading")

        // Создаем вьюмодель с искусственной задержкой
        let delayedMockService = DelayedMockNetworkService()
        let testViewModel = MainViewModel(context: mockContext, networkService: delayedMockService)

        // Запускаем загрузку данных
        let task = Task {
            await testViewModel.loadTableData()
        }

        // Даем немного времени на обновление isLoading = true
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 сек
        XCTAssertTrue(testViewModel.isLoading, "Should set loading to true after start")

        // Ждем завершения загрузки
        await task.value

        // Проверяем финальное состояние
        XCTAssertFalse(testViewModel.isLoading, "Should set loading to false after finishing")
    }

    // MARK: Пустое хранилище до начала работы приложения
    func testInitialItemsEmpty() {
        XCTAssertTrue(viewModel.items.isEmpty, "Initially items should be empty")
    }

    // MARK: Сохранение элементов списка в CoreData
    func testSaveTodoItemToCoreData() {
        let testItems = [
            ToDoItem(id: 100, todo: "Test 1", completed: false, userId: 1),
            ToDoItem(id: 101, todo: "Test 2", completed: true, userId: 1)
        ]
        viewModel.saveTodoItemToCoreData(testItems, context: mockContext)
        let fetchRequest: NSFetchRequest<ToDoEntity> = ToDoEntity.fetchRequest()
        let items = try? mockContext.fetch(fetchRequest)
        XCTAssertEqual(items?.count, 2)
    }

    // MARK: Добавление элемента в CoreData
    func testAddItem() {
        XCTAssertEqual(viewModel.items.count, 0)
        viewModel.addItem(title: "Test", todo: "Test todo", date: "01/01/2025")
        let expectation = XCTestExpectation(description: "Wait for CoreData update")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(self.viewModel.items.count, 1)
            XCTAssertEqual(self.viewModel.items.first?.title, "Test")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: Удаление элемента из CoreData
    func testDeleteItem() {
        viewModel.addItem(title: "Test", todo: "Test todo", date: "01/01/2025")
        let expectation = XCTestExpectation(description: "Wait for operations")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard let item = self.viewModel.items.first else {
                XCTFail("Item not added")
                return
            }
            self.viewModel.deleteItem(item: item)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                XCTAssertTrue(self.viewModel.items.isEmpty)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 2.0)
    }

    // MARK: Тест корректного формирования даты
    func testDateFormatter() {
        let date = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 1))!
        let formatted = viewModel.dateFormatter(date: date)
        XCTAssertEqual(formatted, "01/01/2025")
    }

    // MARK: Тест корректного формирования даты
    func testTaskWordCount() {
        XCTAssertEqual(viewModel.taskWordCount(for: 1), "задача")
        XCTAssertEqual(viewModel.taskWordCount(for: 2), "задачи")
        XCTAssertEqual(viewModel.taskWordCount(for: 5), "задач")
        XCTAssertEqual(viewModel.taskWordCount(for: 11), "задач")
        XCTAssertEqual(viewModel.taskWordCount(for: 22), "задачи")
    }

    // MARK: Изменение состояния ячейки (completed - true/false)
    func testToggleItem() {
        viewModel.addItem(title: "Toggle Test", todo: "Test", date: "01/01/2025")

        let expectation = XCTestExpectation(description: "Item toggled")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard let item = self.viewModel.items.first else {
                XCTFail("Item not found")
                return
            }
            let initialCompletedState = item.completed
            self.viewModel.toggleItem(item: item)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                XCTAssertNotEqual(self.viewModel.items.first?.completed, initialCompletedState)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 2.0)
    }

    // MARK: Вызов экрана "Поделиться"
    func testShareItemContent() {
        viewModel.addItem(title: "Share Test", todo: "Share Content", date: "02/02/2025")
        let expectation = XCTestExpectation(description: "Item added")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard let item = self.viewModel.items.first else {
                XCTFail("Item not found")
                return
            }
            self.viewModel.shareItem(item: item)
            XCTAssertEqual(self.viewModel.shareItems.count, 3)
            XCTAssertEqual(self.viewModel.shareItems[0] as? String, "Share Test")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

}
