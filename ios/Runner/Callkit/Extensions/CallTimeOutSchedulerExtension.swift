//
//  CallTimeOutSchedulerExtension.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//


extension CallManager {
    
    
    // Schedule the call timeout using Timer
    func scheduleCallTimeout(duration: TimeInterval) {
        timeoutTimer = Timer.scheduledTimer(timeInterval: duration,
                                            target: self,
                                            selector: #selector(handleCallTimeout),
                                            userInfo: nil,
                                            repeats: false)
    }
    
    
    @objc func handleCallTimeout() {
                
        // Perform the call end action (e.g., report the call as unanswered)
        if let call = currentCall {
            
            if call.isOutGoing{
                
                if call.hasStartedConnecting && !call.hasConnected{
                    provider?.reportCall(with: call.uuid, endedAt: Date(), reason: .unanswered)
                    AgoraManager.shared.callNotAnswered(callUuid: call.uuid)
                    currentCall = nil
                    print("Call timeout occurred of outgoing call \(call.uuid)")
                }
                
            }
            else if(!call.hasStartedConnecting && !call.hasConnected){
                provider?.reportCall(with: call.uuid, endedAt: Date(), reason: .unanswered)
                CallEventHelper.callTimeOut(payload: call.callPayload)
                currentCall = nil
            }
            
        }
        cancelCallTimeout()
    }
    
    
    // Cancel the call timeout if the user answers the call or
    // caller ends the call before the timeout
    func cancelCallTimeout() {
        timeoutTimer?.invalidate()
        timeoutTimer = nil
    }
    
}
