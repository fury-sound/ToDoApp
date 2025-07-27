//
//  NetworkService.swift
//  ToDoApp
//
//  Created by Valery Zvonarev on 26.07.2025.
//

import Foundation

protocol NetworkServiceProtocol {
    func fetchRequest() async throws -> NetworkTodosModel
//    func fetchRequest() async throws -> [ToDoModel]
}

final class NetworkService: NetworkServiceProtocol {
    static var shared = NetworkService()

    init() {}

    let url = URL(string: "https://dummyjson.com/todos?limit=0")

    @MainActor
    func fetchRequest() async throws -> NetworkTodosModel {
//    func fetchRequest() async throws -> [ToDoModel] {

        guard let url else {
            print("fetchRequest - Invalid URL")
            throw URLError(.badURL)
        }

        let (data,response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            print("Invalid server response: \(response)")
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            print("Server error: \(httpResponse.statusCode)")
            print("Response body: \(String(data: data, encoding: .utf8) ?? "N/A")")
            throw URLError(.badServerResponse)
        }

        do {
            let decoder = JSONDecoder()
            let decodedData = try decoder.decode(NetworkTodosModel.self, from: data)
//            let decodedData = try decoder.decode([ToDoModel].self, from: data)
//            let todos = decodedData.todos
            return decodedData
        } catch let DecodingError.dataCorrupted(context) {
            print("Data corrupted: \(context)")
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found: \(context.debugDescription)")
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found: \(context.debugDescription)")
        } catch let DecodingError.typeMismatch(type, context) {
            print("Type '\(type)' mismatch: \(context.debugDescription)")
            debugPrint("Raw response: \(String(data: data, encoding: .utf8) ?? "N/A")")
        } catch {
            print("JSON decoding error: \(error.localizedDescription)")
            throw error
        }
        return NetworkTodosModel(todos: [], total: 0, skip: 0, limit: 0)
    }
}
