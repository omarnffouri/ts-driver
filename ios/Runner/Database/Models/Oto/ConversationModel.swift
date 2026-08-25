//
//  ConversationModel.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//


import Foundation

struct ConversationModel: Codable, Equatable {
    var id: Int?
    var user: ConversationReciverModel?
    var dateTimeInHumans: String?
    var chatAble: Bool?
    var participants: [ParticipantModel]?

    enum CodingKeys: String, CodingKey {
        case id
        case user = "receiver"
        case dateTimeInHumans = "date_time_in_humans"
        case chatAble = "chat_able"
        case participants
    }
}



