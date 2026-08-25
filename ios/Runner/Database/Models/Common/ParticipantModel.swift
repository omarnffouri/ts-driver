//
//  ParticipantModel.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//

struct ParticipantModel: Codable, Equatable, Hashable {
    var id: Int?
    var pid: Int?
    var name: String?
    var phone: String?
    var image: String?
    var modelType: String?
    var isGroupAdmin: Bool?
    var userDesignation: String?

    enum CodingKeys: String, CodingKey {
        case id
        case pid = "p_id"
        case name
        case phone
        case image
        case modelType = "model_type"
        case isGroupAdmin = "is_group_admin"
        case userDesignation = "user_designation"
    }
    
    static func == (lhs: ParticipantModel, rhs: ParticipantModel) -> Bool {
        return lhs.id == rhs.id && lhs.pid == rhs.pid && lhs.modelType == rhs.modelType
    }
    
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(pid)
        hasher.combine(modelType)
    }
}


