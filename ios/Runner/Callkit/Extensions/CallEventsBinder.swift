//
//  CallEventsBinder.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//

extension CallManager {
    
    
    func bindCallEvents() {
        bindRingingEvent()
        bindIncommingCallDeclinedEvent()
        bindCallDeclinedEvent()
        bindCallUserBusyEvent()
        bindCallNotAnsweredEvent()
    }

    private func bindIncommingCallDeclinedEvent() {
        let callChannel : CallChannel = CallChannel.shared
        //
        // unbind previous event listener
        if incommingCallDeclinedSubscription != nil {
            callChannel.unbindIncommingCallDeclinedEvent(incommingCallDeclinedSubscription)
        }

        //
        // bind a new listener
        incommingCallDeclinedSubscription = callChannel.bindIncommingCallDeclinedEvent { [weak self] data in

            guard let strongSelf = self,
                  let call  = strongSelf.currentCall,
                  let conversationId = data.conversationId,
                  conversationId == call.callPayload.conversationId else { return }

            strongSelf.declineIncomingCall(callUuid: call.uuid, conversationId: conversationId)
        }
    }
    
    private func bindRingingEvent() {
        let callChannel : CallChannel = CallChannel.shared
        //
        // unbind previous event listener
        if callRingingSubscription != nil {
            callChannel.unbindCallRingingEvent(callRingingSubscription)
        }
        
        //
        // bind a new listener
        callRingingSubscription = callChannel.bindCallRingingEvent { [weak self] data in
            
            guard let strongSelf = self,
                  let call  = strongSelf.currentCall,
                  data.conversationType != "group",
                  data.conversationId == call.callPayload.conversationId,
                  let agoraCall = AgoraManager.shared.currentCall,
                  call.uuid == agoraCall.uuid else { return }
            
            AgoraManager.shared.callState = .ringing
        }
    }
    
    private func bindCallDeclinedEvent() {
        let callChannel : CallChannel = CallChannel.shared
        //
        // unbind previous event listener
        if callDeclinedSubscription != nil {
            callChannel.unbindCallDeclinedEvent(callDeclinedSubscription)
        }
        
        //
        // bind a new listener
        callDeclinedSubscription = callChannel.bindCallDeclinedEvent { [weak self] data in
            
            guard let strongSelf = self,
                  let call  = strongSelf.currentCall,
                  data.conversationType != "group",
                  data.conversationId == call.callPayload.conversationId else { return }
            
            strongSelf.callDeclinedByUser(callUuid: call.uuid)
        }
    }
    
    private func bindCallNotAnsweredEvent() {
        let callChannel : CallChannel = CallChannel.shared
        //
        // unbind previous event listener
        if noAnswerSubscription != nil {
            callChannel.unbindCallNoAnswerEvent(noAnswerSubscription)
        }
        
        //
        // bind a new listener
        noAnswerSubscription = callChannel.bindCallNoAnswerEvent { [weak self] data in
            
            guard let strongSelf = self,
                  let call  = strongSelf.currentCall,
                  data.conversationType != "group",
                  data.conversationId == call.callPayload.conversationId else { return }
            
            strongSelf.callNotAnswered(callUuid: call.uuid)
        }
    }
    
    private func bindCallUserBusyEvent() {
        let callChannel : CallChannel = CallChannel.shared
        //
        // unbind previous event listener
        if userBusySubscription != nil {
            callChannel.unbindCallUserBusyEvent(userBusySubscription)
        }
        
        //
        // bind a new listener
        userBusySubscription = callChannel.bindCallUserBusyEvent { [weak self] data in
            
            guard let strongSelf = self,
                  let call  = strongSelf.currentCall,
                  data.conversationType != "group",
                  data.conversationId == call.callPayload.conversationId else { return }
            
            strongSelf.callUserBusy(callUuid: call.uuid)
        }
    }
    
}
