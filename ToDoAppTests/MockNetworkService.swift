//
//  MockNetworkService.swift
//  ToDoAppTests
//
//  Created by Valery Zvonarev on 29.07.2025.
//

import Foundation
import XCTest
import CoreData
@testable import ToDoApp

final class MockNetworkService: NetworkServiceProtocol {
    func fetchRequest() async throws -> NetworkTodosModel {
        let todos = [
            ToDoItem(id: 1, todo: "test 1", completed: false, userId: 10),
            ToDoItem(id: 2, todo: "test 2", completed: true, userId: 20)
        ]
        return  NetworkTodosModel(todos: todos, total: 2, skip: 0, limit: 2)
    }
}
