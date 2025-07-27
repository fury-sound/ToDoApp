//
//  MainModel.swift
//  ToDoApp
//
//  Created by Valery Zvonarev on 26.07.2025.
//

import Foundation

struct MainModel: Identifiable, Codable, Hashable {
    var id: Int
    var title: String
    var todo: String
    var completed: Bool
    var date: String

//    enum CodingKeys: String, CodingKey {
//        case id
//        case title
//        case price
//        case imageUrl = "image"
//    }
}
