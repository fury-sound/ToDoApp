//
//  MainViewTests.swift
//  ToDoAppTests
//
//  Created by Valery Zvonarev on 29.07.2025.
//

import XCTest
import CoreData
@testable import ToDoApp

@MainActor
final class MainViewTests: XCTestCase {
    var view: MainView!
    var viewModel: MainViewModel!
    var mockContext: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        let container = NSPersistentContainer(name: "ToDoApp")
        container.persistentStoreDescriptions[0].url = URL(fileURLWithPath: "/dev/null")

        let expectation = expectation(description: "Load persistent store")
        container.loadPersistentStores { _, error in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)

        mockContext = container.viewContext
        viewModel = MainViewModel(context: mockContext)
    }

    // MARK: Функционирование поиска
    func testSearchFunctionality() {
        // 1. Добавляем тестовый элемент
        viewModel.addItem(title: "Test", todo: "Search test content", date: "01/01/2025")

        // 2. Ждем пока элемент добавится в CoreData
        let addExpectation = XCTestExpectation(description: "Item added to CoreData")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            addExpectation.fulfill()
        }
        wait(for: [addExpectation], timeout: 1.0)
        view = MainView(context: mockContext, viewModel: viewModel)

        // 3. Выполняем поиск
        view.searchQuery = "content" // Ищем по части текста

        // 4. Проверяем результаты поиска
        let searchExpectation = XCTestExpectation(description: "Search completed")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(self.view.searchedItems.count, 1, "Should find one item")
            XCTAssertEqual(self.view.searchedItems.first?.todo, "Search test content")
            searchExpectation.fulfill()
        }
        wait(for: [searchExpectation], timeout: 1.0)
    }

    // MARK: Пустое состояние списка элементов
    func testEmptyState() {
        viewModel.items = []
        view = MainView(context: mockContext, viewModel: viewModel)
        XCTAssertTrue(view.searchedItems.isEmpty)
    }
}
