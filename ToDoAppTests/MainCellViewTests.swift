//
//  MainCellViewTests.swift
//  ToDoAppTests
//
//  Created by Valery Zvonarev on 29.07.2025.
//

import XCTest
import CoreData
import SwiftUI
@testable import ToDoApp

final class MainCellViewTests: XCTestCase {

    // MARK: На краш, если значения title/todo/date = nil и completed = false
    func testRenderingWithNilValues() {
        let context = PersistenceController.shared.container.viewContext
        let item = ToDoEntity(context: context)
        // deliberately do not set title, todo, date
        item.completed = false

        let view = MainCellView(toDoItem: item, isPressed: false)
        let hosting = UIHostingController(rootView: view)

        XCTAssertNotNil(hosting.view) // просто проверка на безопасный рендер
    }

    // MARK: проверка состояния completed = true, с заполненными остальными полями
    func testCompletedRendering() {
        let context = PersistenceController.shared.container.viewContext
        let item = ToDoEntity(context: context)
        item.completed = true
        item.title = "Done"
        item.todo = "Completed task"
        item.date = "01/01/2025"

        let view = MainCellView(toDoItem: item, isPressed: false)
        let hosting = UIHostingController(rootView: view)

        XCTAssertNotNil(hosting.view)
    }

    // MARK: На краш, если completed = true
    func testCompletedState() {
        let context = PersistenceController.shared.container.viewContext
        let item = ToDoEntity(context: context)
        item.completed = true

        let view = MainCellView(toDoItem: item, isPressed: false)
        let hosting = UIHostingController(rootView: view)

        XCTAssertNotNil(hosting.view)
    }
}
