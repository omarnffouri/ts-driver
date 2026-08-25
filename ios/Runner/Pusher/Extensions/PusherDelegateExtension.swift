//
//  PusherDelegateExtension.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//


import Foundation
import PusherSwift

extension PusherManager : PusherDelegate {
    
    
    
    func changedConnectionState(from old: ConnectionState, to new: ConnectionState) {
        printLog("Connection state changed from \(old.stringValue()) to \(new.stringValue())")
    }
    
    func debugLog(message: String) {
        printLog("Debug pusher: \(message)")
    }
    
    func subscribedToChannel(name: String) {
        printLog("Subscribed to channel \(name)")
    }
    
    func failedToSubscribeToChannel(name: String, response: URLResponse?, data: String?, error: NSError?) {
        printLog("Failed to subscribe to channel \(name)")
    }
    
    func receivedError(error: PusherError) {
        let message = error.message
        if let code = error.code {
            printLog("Pusher Error \(code): \(message)")
        }
    }
    
    func failedToDecryptEvent(eventName: String, channelName: String, data: String?) {
        printLog("Failed to decrypt event \(eventName) on channel \(channelName)")
    }
    
}
