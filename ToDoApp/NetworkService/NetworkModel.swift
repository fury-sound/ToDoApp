//
//  NetworkModel.swift
//  ToDoApp
//
//  Created by Valery Zvonarev on 26.07.2025.
//

import Foundation

public struct NetworkTodosModel: Codable {
    var todos: [ToDoItem]
    var total: Int
    var skip: Int
    var limit: Int

    enum CodingKeys: String, CodingKey {
        case todos
        case total
        case skip
        case limit
    }
}

public struct ToDoItem: Identifiable, Codable, Equatable, Hashable {
    public var id: Int
    var todo: String
    var completed: Bool
    var userId: Int

    enum CodingKeys: String, CodingKey {
        case id
        case todo
        case completed
        case userId = "userId"
    }
}
