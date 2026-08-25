//
//  GroupSettingsModel.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//


import Foundation

class GroupSettingsModel: ObservableObject ,Codable, Equatable, Hashable {
    var id: Int?
    var name: String?
    var logo: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case logo
    }
    
    static func == (lhs: GroupSettingsModel, rhs: GroupSettingsModel) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.logo == rhs.logo
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(logo)
    }
}
