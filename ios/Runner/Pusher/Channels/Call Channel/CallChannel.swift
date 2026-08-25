//
//  CallChannel.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//


import PusherSwift

class CallChannel {
    
    static let shared = CallChannel()
    
    
    private let pusherManager: PusherManager = PusherManager.shared
    
    
    // MARK: - Call Channle
    private var callChannel : PusherChannel?
    private let decoder = JSONDecoder()

    
    init() {
        createAndSubscribeCallChannel()
    }
    
    //
    // function to ensure socket connection and callChannel and return call channel
    func getCallChannel() -> PusherChannel? {
        pusherManager.ensureConnection()
        if callChannel == nil{
            createAndSubscribeCallChannel()
        }
        return callChannel
    }

    //
    // function that will ensure call channel subscriptin and bind events
    private func createAndSubscribeCallChannel() {
        
        guard let myDetails = MyDetails.loadFromSharedPrefs(),
              let modelType = myDetails.modelType,
              let userId = myDetails.applicantId else {
            return
        }
        
        pusherManager.ensureConnection()
        
        if callChannel?.subscribed == true {
            printLog("Call Channel already subscribed")
            return
        }
        
        callChannel = pusherManager.getPusher().subscribe(channelName: "private-call-receiver-\(modelType)-\(userId)")
    }
  
    func printLog(_ message: String) {
        print("Pusher Call Channel: \(message)")
    }
}



