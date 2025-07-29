//
//  NetworkServiceProtocol.swift
//  ToDoApp
//
//  Created by Valery Zvonarev on 29.07.2025.
//

import Foundation

public protocol NetworkServiceProtocol {
    func fetchRequest() async throws -> NetworkTodosModel
}
