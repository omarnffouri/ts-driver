//
//  AgoraDelegateExtension.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//

import AgoraRtcKit

extension AgoraManager : AgoraRtcEngineDelegate{
    
    
    // When a remote user joins the channel, display the remote video stream of the specified uid
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int){
        print("User \(uid) joined after \(elapsed) milliseconds")
        
        remoteUserJoined = true
        
        startCallRecording()
        
        startCallTimer()
        
        // if current call connected date is not locked then lock connected date
        if currentCall?.hasConnected == false {
            print("Locking connected date")
            currentCall?.callConnected()
        }
        else{
            print("Already connected date locked")
        }
        
        //
        // check if call state was not connected make it connected
        if callState != .connected{
            callState = .connected
        }
        
        //
        // check if call was outgoing and not connected then notify call manager that call is connected
        if CallManager.shared.currentCall?.isOutGoing == true {
            CallManager.shared.reportOutgoingCallStatusToConnected()
        }
        
        // get the participant model of the remote joined user
        let participant = self.participants.first(where: { item in
            guard let pid = item.pid else { return false }
            return pid == uid
        })
        
        // build a call user against the participant/remote user
        let user = CallUser(remoteId: Int(uid), participant: participant)
        
        
        //
        // check if user already not exist in call users list then add user to call users list
        let alreadyExists = self.callUsers.contains(where: {$0.remoteId == user.remoteId})
        if !alreadyExists{
            self.callUsers.append(user)
        }
        
    }
    
    // Callback when the remote user or anchor leaves the current channel
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        print("User \(uid) went offline due to \(reason)")
        
        
        //
        // remove the remote user from the callUsers list
        self.callUsers.removeAll(where: {$0.remoteId == Int(uid)})
        
        
        //
        // if user who left the call was a selectedCallUser then make selectedCallUser -> nil
        if(self.selectedCallUser?.remoteId == Int(uid)){
            self.selectedCallUser = nil
        }
        
        
        //
        // check if callUser list is empty means all users left the call, now I can end the call
        if(self.callUsers.isEmpty){
            
            //
            // check if its a group video call and their is a still user in a selectedCallUser means
            // their is a one user in the call, no need to end the call
            if(currentCall?.callPayload.conversationType == "group" &&
               currentCall?.callPayload.callType == "video" &&
               self.selectedCallUser != nil){
                print("selectedCallUser is not null in group video call, so cannot end call on user leaving")
                return
            }
            
            //
            // callUsers list empty, and selectedCallUser is nil in case of group  video call
            // now end the call
            endCall()
        }
        
    }
    
    
    // Callback for successful joining the channel
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        print("didJoinChannel: \(channel), uid: \(uid)")
    }
    
    
    func rtcEngine(_ engine:AgoraRtcEngineKit, didLeaveChannelWith: AgoraChannelStats) {
        print("didLeaveChannelWith: \(didLeaveChannelWith)")
    }
    
    
    
    func rtcEngine(_ engine:AgoraRtcEngineKit, didVideoMuted: Bool, byUid: UInt) {
        print("didVideoMuted: \(didVideoMuted), uid: \(byUid)")
        
        if let user = selectedCallUser, user.remoteId == byUid {
            user.videoMuted = didVideoMuted
        } else {
            if let user = callUsers.first(where: { $0.remoteId == byUid }) {
                user.videoMuted = didVideoMuted
            }
        }
    }
    
    
    func rtcEngine(_ engine:AgoraRtcEngineKit, activeSpeaker: UInt){
        print("activeSpeaker: \(activeSpeaker), uid: \(activeSpeaker)")
        
        if let user = selectedCallUser, user.remoteId == activeSpeaker {
            user.isSpeaking = true
        }
        
        for user in callUsers {
            user.isSpeaking = user.remoteId == activeSpeaker
        }
    }
    
    
    func rtcEngine(_ engine:AgoraRtcEngineKit, didAudioMuted: Bool, byUid: UInt){
        print("didAudioMuted: \(didAudioMuted), uid: \(byUid)")
        
        if let user = selectedCallUser, user.remoteId == byUid {
            user.micMuted = didAudioMuted
        } else {
            if let user = callUsers.first(where: { $0.remoteId == byUid }) {
                user.micMuted = didAudioMuted
            }
        }
    }
    
    
    func rtcEngine(_ engine: AgoraRtcEngineKit,didOccurError errorCode: AgoraErrorCode) {
        print("didOccurError: \(errorCode)")
        
        if errorCode == .tokenExpired {
            print("Token has expired.")
            
            // fetch a new token and renew it
            getAgoraToken(){ [weak self] token in
                guard let newToken = token, let strongSelf = self else { return }
                strongSelf.agoraEngine?.renewToken(newToken)
            }
        }
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, tokenPrivilegeWillExpire token: String) {
        print("Token is about to expire. Token: \(token)")
        
        // fetch a new token and renew it
        getAgoraToken(){ [weak self] token in
            guard let newToken = token, let strongSelf = self else { return }
            strongSelf.agoraEngine?.renewToken(newToken)
        }
    }
    
    
    func rtcEngine(_ engine: AgoraRtcEngineKit,connectionChangedTo state: AgoraConnectionState,reason: AgoraConnectionChangedReason){
        
        if state == AgoraConnectionState.failed,
           let call = currentCall,
           call.hasConnected == false{
            failedToLoadRequiredData(callUuid: call.uuid)
        }
        
    }
    
}
