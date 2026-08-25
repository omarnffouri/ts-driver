//
//  ConversationReciverModel.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//


struct ConversationReciverModel: Codable, Equatable {
    var id: Int?
    var phone: String?
    var name: String?
    var image: String?
    var modelType: String?

    enum CodingKeys: String, CodingKey {
        case id
        case phone
        case modelType = "model_type"
        case name
        case image
    }
}
