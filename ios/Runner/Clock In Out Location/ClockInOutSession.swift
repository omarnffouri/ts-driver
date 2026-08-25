//
//  ClockInOutSession.swift
//  Runner
//
//  Created by Hashim Khan on 14/11/2024.
//

import Foundation


class ClockInOutSession  {
    
    public static let SessionId : String = "flutter.sessionId"
    public static let IsStagingServer : String = "flutter.isStagingServer"
    
    
    init(sessionId: String? = nil, isStagingServer: Bool? = nil) {
        self.sessionId = sessionId
        self.isStagingServer = isStagingServer
    }
    
    func toDictionary() -> [String : Any] {
        return [
            "sessionId" : sessionId ?? "",
            "isStagingServer" : isStagingServer ?? true
        ]
    }
    
    static func loadFromSharedPrefs() -> ClockInOutSession?{
        
        let sessionId = UserDefaults.standard.string(forKey: SessionId)
        let isStagingServer = UserDefaults.standard.bool(forKey: IsStagingServer)
        
        if((sessionId ?? "").isEmpty){
            return nil
        }
        
        let obj = ClockInOutSession()
        obj.sessionId = sessionId
        obj.isStagingServer = isStagingServer
        return obj
    }
    
    static func clearSession(){
        UserDefaults.standard.removeObject(forKey: SessionId)
        UserDefaults.standard.removeObject(forKey: IsStagingServer)
    }


    var sessionId: String? = nil
    var isStagingServer: Bool? = nil

}

