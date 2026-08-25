//
//  AgoraListenersForCallKit.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//


extension AgoraManager {
    
    //
    // function to handle a end call triggered from a call manager
    func callEndedFromCallManager(callUuid: UUID) {
        guard callUuid == currentCall?.uuid else { return }
        print("call ended called from call kit in agora manager ===> \(callUuid)")
        
        stopCallTimer()
        if let payload = currentCall?.callPayload, remoteUserJoined , totalTicks > 0 {
            Task{
                await callEndedEventApi.callEnded(payload: payload, callSeconds: totalTicks)
            }
        }
        
        leaveChannel(){ success in
            print("leave channel success (CallManager)===> \(success)")
        }
        NativeCallingEventChannel.shared.sendEvent(event: .callEnded, data: currentCall?.callPayload.toDictionary() ?? [])
        resetAgoraManager()
    }
    
    
    //
    // function to handle a hold call triggered from a call manager
    func holdCallFromCallManager(callUuid: UUID, hold: Bool) {
        guard callUuid == currentCall?.uuid else { return }
        print("hold call called (CallManager)===> \(hold)")
    }
    
    
    //
    // function to handle a mute call audio triggered from a call manager
    func muteAudioFromCallManager(callUuid: UUID,mute: Bool)  {
        guard callUuid == currentCall?.uuid else { return }
        print("mute audio called (CallManager)===> \(mute)")
        audioMuted = mute
        self.agoraEngine?.muteLocalAudioStream(audioMuted)
        
    }
    
    //
    // function to handle a mute call video triggered from a call manager
    func muteVideoFromCallManager(callUuid: UUID,mute: Bool) {
        guard callUuid == currentCall?.uuid else { return }
        print("mute video called (CallManager)===> \(mute)")
        videoMuted = mute
        self.agoraEngine?.muteLocalVideoStream(videoMuted)
    }
    
    
    //
    // function to update call status and handle when outgoing call declined by user
    func callDeclinedByUser(callUuid: UUID) {
        guard callUuid == currentCall?.uuid else { return }
        callState = .declined
        stopCallTimer()
        leaveChannel(){ success in
            print("leave channel success (CallManager) (call declined)===> \(success)")
        }
        NativeCallingEventChannel.shared.sendEvent(event: .callDeclined, data: currentCall?.callPayload.toDictionary() ?? [])
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.resetAgoraManager()
        })
    }
    
    
    //
    // function to update call status and handle when user busy on outgoing call
    func callUserBusy(callUuid: UUID) {
        guard callUuid == currentCall?.uuid else { return }
        callState = .userBusy
        stopCallTimer()
        leaveChannel(){ success in
            print("leave channel success (CallManager) (call user busy)===> \(success)")
        }
        NativeCallingEventChannel.shared.sendEvent(event: .callUserBusy, data: currentCall?.callPayload.toDictionary() ?? [])
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.resetAgoraManager()
        })
    }
    
    //
    // function to update call status and handle when user not answered the call
    func callNotAnswered(callUuid: UUID) {
        guard callUuid == currentCall?.uuid else { return }
        callState = .notAnswered
        stopCallTimer()
        leaveChannel(){ success in
            print("leave channel success (CallManager) (call no answer)===> \(success)")
        }
        NativeCallingEventChannel.shared.sendEvent(event: .callNoAnswer, data: currentCall?.callPayload.toDictionary() ?? [])
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.resetAgoraManager()
        })
    }
}
