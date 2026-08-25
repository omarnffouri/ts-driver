//
//  StartCallRecordingModel.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//


import Foundation

struct StartCallRecordingModel: Equatable, Codable {


    let cname: String?
    let uid: String?
    let resourceId: String?
    let sid: String?

   
    private enum CodingKeys: String, CodingKey {
        case cname
        case uid
        case resourceId
        case sid
    }
}
