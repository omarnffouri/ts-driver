//
//  GroupConversationModel.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//


import Foundation

struct GroupConversationModel: Codable, Equatable {
    var id: Int?
    var name: String?
    var groupSettings: GroupSettingsModel?
    var participants: [ParticipantModel]?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case groupSettings = "group_setting"
        case participants
    }
}
