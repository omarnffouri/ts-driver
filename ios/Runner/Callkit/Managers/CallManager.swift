//
//  CallManager.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//


import UIKit
import CallKit
import PusherSwift
import AVFAudio

class CallManager: NSObject {
    
    static  let shared = CallManager()
    
    var provider: CXProvider?
    let callController = CXCallController()
    var timeoutTimer: Timer?
    var currentCall: Call?
    
    
    // MARK: - Call Events Subscriptions
    var callRingingSubscription : String?
    var incommingCallDeclinedSubscription : String?
    var callDeclinedSubscription : String?
    var userBusySubscription : String?
    var noAnswerSubscription : String?
    
    
    override init() {
        super.init()
        provider = CXProvider(configuration: createCXProviderConfigs())
        provider?.setDelegate(self, queue: nil)
    }
    
    
    // function to create to create the CXProviderConfiguration
    func createCXProviderConfigs() -> CXProviderConfiguration {
        let configuration = CXProviderConfiguration()
        configuration.supportsVideo = true
        configuration.supportedHandleTypes = [.generic]
        if let image = UIImage(named: "AppIcon") {
            configuration.iconTemplateImageData = image.pngData()
        }
        
        return configuration;
    }
    
    
    
    
    
    func declineIncomingCall(callUuid : UUID, conversationId : Int? = nil) {
        // Only a still-ringing incoming call can be cancelled by the caller;
        // never tear down a call that was already answered.
        guard let call = currentCall,
              !call.isOutGoing,
              !call.hasStartedConnecting,
              !call.hasConnected else { return }

        // temp_call_id is not always a valid UUID string, in which case both
        // pushes fall back to random UUIDs that can never match — so also
        // accept a match on the conversation.
        let matchesUuid = call.uuid.uuidString == callUuid.uuidString
        let matchesConversation = conversationId != nil && conversationId != 0
            && conversationId == call.callPayload.conversationId

        guard matchesUuid || matchesConversation else { return }

        provider?.reportCall(with: call.uuid, endedAt: Date(), reason: .remoteEnded)
        currentCall = nil
        cancelCallTimeout()
        InterruptionNotificationManager.shared.sendAudioInterruptionEndNotification()
    }
    
    func placeOutgoingCall(call : Call, completion : @escaping (Bool) -> Void) {
        
        CallChannel.shared.printLog("Initializing the call channel on place call in call manager")
        
        if(currentCall != nil){
            completion(false)
            return
        }
        let handle = CXHandle(type: .generic, value: call.callPayload.receiverName ?? "")

        let startCallAction = CXStartCallAction(call: call.uuid, handle: handle)
        let transaction = CXTransaction(action: startCallAction)

        callController.request(transaction) { error in
            if let error = error {
                completion(false)
                print("Error reporting outgoing call: \(error)")
            } else {
                completion(true)
                                
                let handle = CXHandle(type: .generic, value: call.callPayload.receiverName ?? "")
                let callUpdate = CXCallUpdate()
                callUpdate.remoteHandle = handle
                callUpdate.hasVideo = call.callPayload.callType == "video" ? true : false
                callUpdate.localizedCallerName = call.callPayload.callerName ?? ""
                self.provider?.reportCall(with: call.uuid, updated: callUpdate)
                
                print("Outgoing call reported successfully")
                
            }
        }
        
        currentCall = call
        
        bindCallEvents()
        
        AgoraManager.shared.placeCall(call: call)
        
        // schedule timeout for outgoing call
        self.scheduleCallTimeout(duration: 30)
    }

    
    
    func reportOutgoingCallStatusToConnecting() {
        guard let call = currentCall else { return }
        call.callStarted()
        provider?.reportOutgoingCall(with: call.uuid, startedConnectingAt: Date())
    }
    
    
    func reportOutgoingCallStatusToConnected() {
        guard let call = currentCall else { return }
        call.callConnected()
        provider?.reportOutgoingCall(with: call.uuid, connectedAt: Date())
        // cancel scheduled timeout for outgoinng call
        self.cancelCallTimeout()
    }
    
    

    // Returns false when no call was reported to CallKit (receiver busy) so
    // the VoIP push handler can still satisfy the report requirement.
    @discardableResult
    func reportIncomingCall(call : Call) -> Bool {

        if(currentCall != nil){
            CallEventHelper.userBusy(payload: call.callPayload)
            return false
        }

        // Prewarm the engine + set the audio category while ringing so the first
        // cold-start call has audio.
        AgoraManager.shared.prewarm()
        configureCallAudioSessionCategory()

        let callUpdate = CXCallUpdate()
        callUpdate.remoteHandle = CXHandle(type: .generic, value: call.callPayload.callerName ?? "")
        callUpdate.supportsDTMF = true
        callUpdate.supportsHolding = true
        callUpdate.supportsGrouping = false
        callUpdate.supportsUngrouping = false
        callUpdate.hasVideo = call.callPayload.callType == "video" ? true : false
        callUpdate.localizedCallerName = call.callPayload.callerName ?? ""
        
        
        provider?.reportNewIncomingCall(with: call.uuid , update: callUpdate, completion: { error in
            if let error = error {
                print("Error reporting incoming call: \(error.localizedDescription)")
                return
            }
            
            // incomming call reported successfully, now store its record
            self.currentCall = call
            
            // emitting ringing event to server
            CallEventHelper.callRinging(payload: call.callPayload)
            
            // schedule timeout for incomming call
            self.scheduleCallTimeout(duration: 30)

            // listen for call events (e.g. caller cancelling) while ringing
            self.bindCallEvents()

        })

        return true
    }

    // Set the .playAndRecord category (no activation — CallKit owns that).
    func configureCallAudioSessionCategory() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playAndRecord,
                mode: .voiceChat,
                options: [.allowBluetooth, .allowAirPlay]
            )
        } catch {
            print("Error pre-configuring call audio session category: \(error)")
        }
    }

    func endCall(callUuid : UUID?) {
        
        var uid : UUID = UUID()
        
        if(callUuid != nil){
            uid = callUuid!
        }
        else if(currentCall != nil){
            uid = currentCall!.uuid
        }
        else {
            return
        }
        
        let endCallAction = CXEndCallAction(call: uid)
        let callTransaction = CXTransaction()
        callTransaction.addAction(endCallAction)
        self.callController.request(callTransaction) { _ in
            
        }
    }
    
    func failedToJoinCall(callUuid : UUID?) {
        
        var uid : UUID = UUID()
        
        if(callUuid != nil){
            uid = callUuid!
        }
        else if(currentCall != nil){
            uid = currentCall!.uuid
        }
        else {
            return
        }
        
        self.provider?.reportCall(with: uid, endedAt: Date(), reason: .failed)
        self.currentCall = nil
    }
    
    func callDeclinedByUser(callUuid : UUID?) {
        
        var uid : UUID = UUID()
        
        if(callUuid != nil){
            uid = callUuid!
        }
        else if(currentCall != nil){
            uid = currentCall!.uuid
        }
        else {
            return
        }
        
        self.provider?.reportCall(with: uid, endedAt: Date(), reason: .remoteEnded)
        AgoraManager.shared.callDeclinedByUser(callUuid:  uid)
        self.currentCall = nil
    }

    func callUserBusy(callUuid : UUID?) {
        
        var uid : UUID = UUID()
        
        if(callUuid != nil){
            uid = callUuid!
        }
        else if(currentCall != nil){
            uid = currentCall!.uuid
        }
        else {
            return
        }
        
        self.provider?.reportCall(with: uid, endedAt: Date(), reason: .unanswered)
        AgoraManager.shared.callUserBusy(callUuid: uid)
        self.currentCall = nil
    }
    
    func callNotAnswered(callUuid : UUID?) {
        
        var uid : UUID = UUID()
        
        if(callUuid != nil){
            uid = callUuid!
        }
        else if(currentCall != nil){
            uid = currentCall!.uuid
        }
        else {
            return
        }
        
        self.provider?.reportCall(with: uid, endedAt: Date(), reason: .unanswered)
        AgoraManager.shared.callNotAnswered(callUuid: uid)
        self.currentCall = nil

    }
    
    
    func providerDidReset(_ provider: CXProvider) {
        
    }
    
    
    
}






