//
//  CallEventDataModel.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//


import Foundation

class CallEventDataModel : Codable, Equatable{
    
    
    var channelName: String?
    var conversationId: Int?
    var conversationType: String?
    var callType: String?
    
    enum CodingKeys: String, CodingKey {
        case channelName
        case conversationId
        case conversationType
        case callType
    }
    
    
    static func == (lhs: CallEventDataModel, rhs: CallEventDataModel) -> Bool {
        return lhs.channelName == rhs.channelName &&
        lhs.conversationId == rhs.conversationId &&
        lhs.conversationType == rhs.conversationType &&
        lhs.callType == rhs.callType
    }
}
