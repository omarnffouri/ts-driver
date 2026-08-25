//
//  ProviderDelegateExtension.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//


import CallKit
import AVFAudio
import SwiftUI


extension CallManager : CXProviderDelegate {
    
    
    
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        print("Start Call \(action.callUUID)")
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        guard let call = currentCall, call.uuid == action.callUUID else {
            action.fail()
            return
        }
        
        if(!call.hasConnected && !call.hasStartedConnecting && !call.isOutGoing){
            CallEventHelper.callRejected(payload: call.callPayload)
            InterruptionNotificationManager.shared.sendAudioInterruptionEndNotification()
        }
        else if call.isOutGoing && !call.hasConnected{
            CallEventHelper.ongoingCallDeclined(payload: call.callPayload)
        }
        
        cancelCallTimeout()
        AgoraManager.shared.callEndedFromCallManager(callUuid: call.uuid)
        currentCall = nil
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        guard let call = currentCall, call.uuid == action.callUUID else {
            action.fail()
            return
        }
        
        // Set the category before fulfill(); CallKit activates the session next.
        configureCallAudioSessionCategory()

        call.callAccepted()
        AgoraManager.shared.callAccepted(call: call)
        cancelCallTimeout()
        openFullScreenView()
        action.fulfill()
    }


    func openFullScreenView() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let window = windowScene.windows.first {
                let rootView = CallScreenView() // Your SwiftUI view for the call screen
                let hostingController = UIHostingController(rootView: rootView)
                hostingController.modalPresentationStyle = .fullScreen
                window.rootViewController?.present(hostingController, animated: true, completion: nil)
            }
        }
    }
    
    public func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) {
        currentCall = nil
        InterruptionNotificationManager.shared.sendAudioInterruptionEndNotification()
        action.fulfill()
    }
    
    public func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        guard let call = currentCall ,call.uuid == action.callUUID else {
            action.fail()
            return
        }
        
        call.isOnHold = action.isOnHold
        AgoraManager.shared.holdCallFromCallManager(callUuid: call.uuid, hold: action.isOnHold)
        action.fulfill()
    }
    
    public func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        guard let call = currentCall, call.uuid == action.callUUID else {
            action.fail()
            return
        }
        
        call.isMuted = action.isMuted
        AgoraManager.shared.muteAudioFromCallManager(callUuid: call.uuid, mute: action.isMuted)
        action.fulfill()
    }
    
    public func provider(_ provider: CXProvider, perform action: CXSetGroupCallAction) {
        print("Set Group Call")
        action.fulfill()
    }
    
    public func provider(_ provider: CXProvider, perform action: CXPlayDTMFCallAction) {
        print("Play DTMF Call")
        action.fulfill()
    }
    
    public func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        // No .mixWithOthers: a VoIP call must own the route or it can be silent.
        do {
            try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: [.allowBluetooth, .allowAirPlay])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            try AVAudioSession.sharedInstance().setPreferredSampleRate(44100)
        } catch {
            print("Error configuring AVAudioSession: \(error)")
        }

        AgoraManager.shared.audioSessionDidActivate()
    }
    
    public func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
//        if let call = currentCall , !call.isOnHold{
//            call.endCall()
//        }
    }
    
}
