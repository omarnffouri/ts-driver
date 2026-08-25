//
//  PusherManager.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//


import Foundation
import PusherSwift


class PusherManager : ObservableObject {
    
    
    static let shared = PusherManager()
    
    
    private var pusher: Pusher?
    // Realtime config comes from the server (mirrored into UserDefaults by Dart).
    // Honor it as the source of truth; env-based hardcoded values are only a
    // fallback for the window before the first config fetch.
    private var pusherKey: String {
        if let key = MyDetails.realtimeKey() { return key }
        if MyDetails.isProduction() { return "HiXzy5MIniPeS24McIZ1VdIrZ" }
        if MyDetails.isStaging() { return "E17C5BA4D29185A3" }
        return "9dbf5c6a056f4d4f99561fcf43f8a566" // development
    }

    
    // MARK: - Connection Functions
    func initializePusher() {
        
        // Create the Pusher ClientOptions with the custom URL
        let clusterOptions = PusherClientOptions(
            authMethod: AuthMethod.authRequestBuilder(authRequestBuilder: self),
            host: .host(getHost()),
            port: getPort(),
            useTLS: true
        )
        
        pusher = Pusher(key: pusherKey, options: clusterOptions)
        pusher?.connection.delegate = self
        
        // Establish connection
        pusher?.connect()
    }
    
    func disconnect() {
        pusher?.disconnect()
    }
    
    func isConnected() -> Bool {
        return pusher?.connection.connectionState == ConnectionState.connected
    }
    
    func ensureConnection() {
        if !isConnected() {
            printLog("Socket is not connected, attempting to reconnect...")
            guard let pusherInstance = pusher else {
                initializePusher()
                return
            }
            pusherInstance.connect()
        } else {
            printLog("Socket is already connected.")
        }
    }
    
    func getPusher() -> Pusher{
        guard let pusherInstance = pusher else {
            initializePusher()
            return pusher!
        }
        return pusherInstance
    }

    // MARK: - Configs Functions
    private func getHost() -> String {
        if let host = MyDetails.realtimeHost() { return host }
        if MyDetails.isProduction() { return "socket.ts-portal.com" }
        if MyDetails.isStaging() { return "staging.ts-portal.com" }
        return "dev.ts-portal.com" // development
    }

    private func getPort() -> Int {
        return MyDetails.realtimePort() ?? 2096
    }
    

    
    func printLog(_ message: String) {
        print("Pusher: \(message)")
    }
    
}



