//
//  PusherAuthenticatorDelegate.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//

import PusherSwift

extension PusherManager : AuthRequestBuilderProtocol{
    
    
    func requestFor(socketID: String, channelName: String) -> URLRequest? {
        
        guard let token = MyDetails.loadFromSharedPrefs()?.token else { return nil }
        var request = URLRequest(url: URL(string: getAuthUrl())!)
        request.httpMethod = "POST"
        request.httpBody = "socket_id=\(socketID)&channel_name=\(channelName)".data(using: String.Encoding.utf8)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
    
    
    private func getAuthUrl() -> String {
        if let authUrl = MyDetails.realtimeAuthUrl() { return authUrl }
        return  "https://\(MyDetails.isStaging() ? "staging." : MyDetails.isDevelopment() ? "dev." :  "")ts-portal.com/broadcasting/auth"
    }
    
}
