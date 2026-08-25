//
//  AgoraManager.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//

import AgoraRtcKit
import Foundation
import AVFAudio
import SwiftUI

class AgoraManager : NSObject, ObservableObject  {
    
    static let shared = AgoraManager() // singleton instance
    
    
    
    var agoraEngine : AgoraRtcEngineKit?
    private var currentAppId : String?
    var myDetails = MyDetails.loadFromSharedPrefs()
    @Published var currentCall : Call?
    @Published var groupSettings : GroupSettingsModel?

    // Set on accept; CallScreenView gates mic/camera then calls joinAcceptedCall().
    var pendingIncomingJoin = false
    
    
    // MARK:  Apis
    var callEndedEventApi : CallEndedEventApi = CallEndedEventApi()
    var startCallRecordingApi : StartCallRecordingApi = StartCallRecordingApi()
    var stopCallRecordingApi : StopCallRecordingApi = StopCallRecordingApi()
    
    
    // MARK:  Call State/Data Variables
    @Published var myPid : Int?
    @Published var participants : [ParticipantModel] = []
    @Published var callUsers : [CallUser] = []
    @Published var selectedCallUser : CallUser?
    @Published var localUserJoined : Bool = false
    @Published var remoteUserJoined : Bool = false
    @Published var audioMuted : Bool = false
    @Published var videoMuted : Bool = false
    @Published var speakerEnabled : Bool = false
    @Published var callRecording : StartCallRecordingModel?
    @Published var callState : CallState = .idle
    
    
    // MARK: Call Time Variables
    var callTimer: Timer?
    @Published var hours : Int = 0
    @Published var minutes : Int = 0
    @Published var seconds : Int = 0
    @Published var totalTicks : Int = 0
    
    
    override private init() {
        super.init()
        let appId = AgoraManager.desiredAppId()
        self.agoraEngine = AgoraRtcEngineKit.sharedEngine(withAppId: appId, delegate: self)
        self.currentAppId = appId
        applyCallKitAudioSessionRestriction()
    }

    // Prefer the server-synced agora app id, else the hardcoded per-env id.
    private static func desiredAppId() -> String {
        return MyDetails.agoraAppId() ?? (MyDetails.isProduction() ? "b7bfc1ea224b4dc79d2a0fec4b45eb51" : "56ce6ab15eef486aa7b5b798c930042e")
    }

    // CallKit owns the AVAudioSession lifecycle. Restrict the SDK from
    // deactivating it (on leaveChannel / engine teardown / recreate) so that
    // destroying+rebuilding the engine while CallKit's session is active no
    // longer kills audio. Re-applied after every engine (re)creation.
    private func applyCallKitAudioSessionRestriction() {
        agoraEngine?.setAudioSessionOperationRestriction(.deactivateSession)
    }

    // Build the engine at ring time so it's alive when CallKit activates the
    // audio session on answer (cold-start no-audio fix).
    func prewarm() {
        if Thread.isMainThread {
            recreateEngineIfNeeded()
        } else {
            DispatchQueue.main.async { [weak self] in self?.recreateEngineIfNeeded() }
        }
    }

    // Re-bind Agora's audio I/O to the session CallKit just activated.
    func audioSessionDidActivate() {
        guard let engine = agoraEngine else { return }
        engine.enableAudio()
        engine.setEnableSpeakerphone(speakerEnabled)
        engine.muteLocalAudioStream(audioMuted)
    }

    // If the server rotated the agora app id (synced into prefs just before this
    // call), the existing engine still holds the old id and its token would
    // mismatch — rebuild it with the fresh id. Must run on the main thread.
    func recreateEngineIfNeeded() {
        let desired = AgoraManager.desiredAppId()
        if agoraEngine != nil && currentAppId == desired { return }
        AgoraRtcEngineKit.destroy()
        agoraEngine = AgoraRtcEngineKit.sharedEngine(withAppId: desired, delegate: self)
        currentAppId = desired
        applyCallKitAudioSessionRestriction()
    }
    
    
    // MARK: - Join Channel
    private func joinChannel(withToken token: String? = nil, completion: @escaping (Bool) -> Void) {
        
        guard let channelName = currentCall?.callPayload.channelName, let myPid = myPid else {
            completion(false)
            return
        }
        
        agoraEngine?.setChannelProfile(.communication)
        agoraEngine?.enableAudio()
        agoraEngine?.setClientRole(.broadcaster)
        
        if(currentCall?.callPayload.callType == "video"){
            agoraEngine?.enableVideo()
            agoraEngine?.enableLocalVideo(true)
        }
        
        agoraEngine?.joinChannel(byToken: token, channelId: channelName, info: nil, uid: UInt(myPid)) { [weak self] (channel, uid, elapsed) in
            print("Joined channel \(channel) with UID \(uid)")
            
            if let strong = self {
                strong.localUserJoined = true
            }
            completion(true)
        }
    }
    
    // MARK: - Leave Channel
    func leaveChannel(completion: @escaping (Bool) -> Void) {
        agoraEngine?.leaveChannel { [weak self] _ in
            print("Left channel")
            if let strong = self {
                strong.localUserJoined = false
            }
            completion(true)
        }
    }
    
    
    
    // MARK: - Setup Local Video
    func setupLocalVideo(view: UIView) {
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = 0
        videoCanvas.view = view
        videoCanvas.renderMode = .hidden
        agoraEngine?.setupLocalVideo(videoCanvas)
    }
    
    // MARK: - Setup Remote Video
    func setupRemoteVideo(uid: UInt, view: UIView) {
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.view = view
        videoCanvas.renderMode = .hidden
        videoCanvas.setupMode = .replace
        agoraEngine?.setupRemoteVideo(videoCanvas)
    }
    
    func removeRemoteVideo(uid: UInt) {
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.view = nil
        videoCanvas.renderMode = .hidden
        videoCanvas.setupMode = .replace
        agoraEngine?.setupRemoteVideo(videoCanvas)
    }
    
    
    
    func getAgoraToken(completion: @escaping (String?) -> Void){
        
        guard let channelName = currentCall?.callPayload.channelName, let pid = myPid else {
            completion(nil)
            return
        }
        
        Task{
            completion(await AgoraTokenApi.getAgoraToken(channelName: channelName , joiningAs: JoiningAs.attendee, pid: pid))
        }
    }

    // Refresh the realtime config (agora app id) before minting the token +
    // joining, so a rotated app id is applied and matches the signed token.
    // Shared by the place + accept call paths; `onJoined` runs on the main
    // queue with the join result once the channel is joined.
    private func syncRecreateTokenThenJoin(callUuid: UUID, onJoined: @escaping (Bool) -> Void) {
        Task { [weak self] in
            await RealtimeConfigApi.sync()
            await MainActor.run { self?.recreateEngineIfNeeded() }
            self?.getAgoraToken() { token in
                DispatchQueue.main.async {
                    guard let token else {
                        print("token is nil")
                        self?.failedToLoadRequiredData(callUuid: callUuid)
                        return
                    }
                    print("token from the api ===> \(token)")
                    self?.joinChannel(withToken: token) { success in
                        onJoined(success)
                    }
                }
            }
        }
    }
    
    
    
    // MARK: - Place call
    func placeCall(call : Call) {
        
        print("place call called from call kit in agora manager ===> \(call.uuid)")
        
        
        CallChannel.shared.printLog("Initializing the call channel on place call in agora manager")
        
        resetAgoraManager()
        self.currentCall = call
        callState = .calling
        
        
        //
        // loads and validates the call data before starting call
        guard loadCallData() else {
            print("Call params validation failed")
            failedToLoadRequiredData(callUuid: call.uuid)
            return
        }
        
        //
        // loading receiver image if call is outgoing
        if call.isOutGoing {
            self.currentCall?.callPayload.receiverImage = getOpositeUserImage()
        }
        
        
        //
        // open full screen UI
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let window = windowScene.windows.first {
                let rootView = CallScreenView() // Your SwiftUI view for the call screen
                let hostingController = UIHostingController(rootView: rootView)
                hostingController.modalPresentationStyle = .fullScreen
                window.rootViewController?.present(hostingController, animated: true, completion: nil)
            }
        }
        
        //
        //notify call manager that call is now connecting
        CallManager.shared.reportOutgoingCallStatusToConnecting()

        syncRecreateTokenThenJoin(callUuid: call.uuid) { [weak self] success in
            print("join channel success ===> \(success)")

            //
            // sending event to flutter layer that call placed
            NativeCallingEventChannel.shared.sendEvent(event: .callPlaced, data: self?.currentCall?.callPayload.toDictionary() ?? [])
        }

    }
    
    
    // MARK: -  Call Accepted
    func callAccepted(call : Call) {
        
        
        
        print("call accepted called from call kit in agora manager ===> \(call.uuid)")
        
        CallChannel.shared.printLog("Initializing the call channel on call accepted in agora manager")
        
        resetAgoraManager()
        self.currentCall = call
        callState = .connecting
        
        //
        // loads and validates the call data before starting call
        guard loadCallData() else {
            print("Call params validation failed")
            failedToLoadRequiredData(callUuid: call.uuid)
            return
        }

        // Defer accepted-emit + join to CallScreenView (it can host the prompt the locked CallKit UI can't).
        pendingIncomingJoin = true
    }

    // Join once permissions resolve; camera-denied video downgrades to audio.
    func joinAcceptedCall(cameraGranted: Bool) {
        guard let call = currentCall, pendingIncomingJoin else { return }
        pendingIncomingJoin = false

        if !cameraGranted && call.callPayload.callType == "video" {
            call.callPayload.callType = "audio"
            objectWillChange.send() // re-render CallScreenView to the audio layout
        }

        // Tell the caller + server "accepted" only now that permissions are granted.
        emitCallAcceptedEvents(call: call)

        callState = .connecting
        syncRecreateTokenThenJoin(callUuid: call.uuid) { [weak self] success in
            print("join channel success ===> \(success)")
            self?.callState = .connected
        }
    }

    // Notify the Flutter layer + the caller (Pusher client-event) + the server
    // (accepted API) that the callee answered. Fired before the media join so a
    // slow/failed Agora join never leaves the caller ringing as 'no answer'.
    private func emitCallAcceptedEvents(call: Call) {
        NativeCallingEventChannel.shared.sendEvent(event: .callReceived, data: call.callPayload.toDictionary())

        CallChannel.shared.getCallChannel()?.trigger(eventName: "client-call-accepted", data: [
            "calledBy": [
                "userId":  call.callPayload.callerId as Any,
                "userModelType":  call.callPayload.callerModelType as Any,
                "userName":  call.callPayload.callerName as Any,
                "userImage":  call.callPayload.callerImage as Any,
            ],
            "conversationId" : call.callPayload.conversationId as Any,
            "isOnCall": "mobile",
        ])

        CallEventHelper.callAccepted(payload: call.callPayload)
    }




    // MARK: - End Call
    func endCall() {
        print("end call called in agora manager")
        
        stopCallTimer()
        if let payload = currentCall?.callPayload, remoteUserJoined , totalTicks > 0 {
            Task{
                await callEndedEventApi.callEnded(payload: payload, callSeconds: totalTicks)
            }
        }
        leaveChannel(){ _ in
        }
        CallManager.shared.endCall(callUuid: self.currentCall?.uuid)
        NativeCallingEventChannel.shared.sendEvent(event: .callEnded, data: currentCall?.callPayload.toDictionary() ?? [])
        resetAgoraManager()
    }
    
    
    
    
    
    // MARK: - Failure Functions
    
    
    //
    // function to handle a failure while loading data after accepting the call
    // might be any data null or failed to load
    func failedToLoadRequiredData(callUuid : UUID?) {
        callState = .failed
        NativeCallingEventChannel.shared.sendEvent(event: .callFailed, data: currentCall?.callPayload.toDictionary() ?? [])
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            CallManager.shared.failedToJoinCall(callUuid: callUuid)
            self.resetAgoraManager()
        })
    }
}

