//
//  MyDetails.swift
//  Runner
//
//  Created by Hashim Khan on 03/01/2024.
//

import Foundation

class MyDetails{
    
    
    
    public static let  Token : String = "flutter.token"
    public static let  FirstName  : String = "flutter.firstName"
    public static let  LastName  : String = "flutter.lastName"
    public static let  UserId  : String = "flutter.userId"
    public static let  ApplicantId  : String = "flutter.applicantId"
    public static let  ModelType  : String = "flutter.modelType"
    public static let  Image  : String = "flutter.image"
    public static let  ServerUrl : String = "flutter.serverUrl"

    // realtime (Pusher/Reverb) config mirrored from the server's
    // realtime-configuration by Dart (SharedPrefrencesHelper.storeRealtimeConfig).
    public static let  RealtimeKey : String = "flutter.realtimeKey"
    public static let  RealtimeHost : String = "flutter.realtimeHost"
    public static let  RealtimePort : String = "flutter.realtimePort"
    public static let  RealtimeAuthUrl : String = "flutter.realtimeAuthUrl"
    public static let  RealtimeAgoraAppId : String = "flutter.realtimeAgoraAppId"
    public static let  RealtimeConfigVersion : String = "flutter.realtimeConfigVersion"

    static func realtimeKey() -> String? {
        let value = UserDefaults.standard.string(forKey: RealtimeKey)
        return (value?.isEmpty ?? true) ? nil : value
    }

    static func realtimeHost() -> String? {
        let value = UserDefaults.standard.string(forKey: RealtimeHost)
        return (value?.isEmpty ?? true) ? nil : value
    }

    static func realtimePort() -> Int? {
        let value = UserDefaults.standard.integer(forKey: RealtimePort)
        return value > 0 ? value : nil
    }

    static func realtimeAuthUrl() -> String? {
        let value = UserDefaults.standard.string(forKey: RealtimeAuthUrl)
        return (value?.isEmpty ?? true) ? nil : value
    }

    // Agora app id mirrored from the server's realtime-configuration; nil when
    // blank so callers can fall back to the hardcoded per-env id.
    static func agoraAppId() -> String? {
        let value = UserDefaults.standard.string(forKey: RealtimeAgoraAppId)
        return (value?.isEmpty ?? true) ? nil : value
    }

    static func realtimeConfigVersion() -> String? {
        let value = UserDefaults.standard.string(forKey: RealtimeConfigVersion)
        return (value?.isEmpty ?? true) ? nil : value
    }

    // Persist a freshly-fetched realtime config into the same Flutter prefs Dart
    // mirrors into, so a cold-start call can self-heal a rotated config without
    // Dart running. Keys match those Dart writes via SharedPrefrencesHelper.
    static func storeRealtimeConfig(
        key: String?,
        host: String?,
        port: Int?,
        authUrl: String?,
        agoraAppId: String?,
        configVersion: String?
    ) {
        let defaults = UserDefaults.standard
        if let key = key, !key.isEmpty { defaults.set(key, forKey: RealtimeKey) }
        if let host = host, !host.isEmpty { defaults.set(host, forKey: RealtimeHost) }
        if let port = port, port > 0 { defaults.set(port, forKey: RealtimePort) }
        if let authUrl = authUrl, !authUrl.isEmpty { defaults.set(authUrl, forKey: RealtimeAuthUrl) }
        if let agoraAppId = agoraAppId, !agoraAppId.isEmpty { defaults.set(agoraAppId, forKey: RealtimeAgoraAppId) }
        if let configVersion = configVersion, !configVersion.isEmpty { defaults.set(configVersion, forKey: RealtimeConfigVersion) }
    }


    
    var token: String?
    var firstName: String?
    var lastName: String?
    var modelType: String?
    var image: String?
    var serverUrl: String?
    var userId: Int?
    var applicantId: Int?
    
    
    
    static func loadFromSharedPrefs() -> MyDetails?{
                
        let token = UserDefaults.standard.string(forKey: Token)
        let firstName = UserDefaults.standard.string(forKey: FirstName)
        let lastName = UserDefaults.standard.string(forKey: LastName)
        let userId = UserDefaults.standard.integer(forKey: UserId)
        let applicantId = UserDefaults.standard.integer(forKey: ApplicantId)
        let modelType = UserDefaults.standard.string(forKey: ModelType)
        let image = UserDefaults.standard.string(forKey: Image)
        let serverUrl = UserDefaults.standard.string(forKey: ServerUrl)
        
        if((token ?? "").isEmpty || (userId <= 0) || (serverUrl ?? "").isEmpty){
            return nil
        } else{
            let obj = MyDetails()
            obj.token = token
            obj.firstName = firstName
            obj.lastName = lastName
            obj.userId = userId
            obj.applicantId = applicantId
            obj.modelType = modelType
            obj.image = image
            obj.serverUrl = serverUrl
            return obj
        }
    }
    
    static func isProduction() -> Bool{
        return ((!isStaging()) && (!isDevelopment()))
    }
    
    
    static func isDevelopment() -> Bool{
        guard let serverUrl = MyDetails.loadFromSharedPrefs()?.serverUrl else {
            return true
        }
        return serverUrl.contains("dev")
    }
    
    static func isStaging() -> Bool{
        guard let serverUrl = MyDetails.loadFromSharedPrefs()?.serverUrl else {
            return true
        }
        return serverUrl.contains("staging")
    }
    
    
}
