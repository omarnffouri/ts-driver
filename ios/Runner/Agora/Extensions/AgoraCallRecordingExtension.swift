//
//  AgoraCallRecordingExtension.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//


extension AgoraManager {
    
    //
    // check if callRecording is nil means call recording was not started
    func startCallRecording() {
        
        guard let callPayload = currentCall?.callPayload,
              let myDetails = MyDetails.loadFromSharedPrefs(),
              callPayload.callerId == myDetails.applicantId,
              callPayload.callerModelType == myDetails.modelType  else { return }
        
        
        if(callRecording == nil && !startCallRecordingApi.isLoading){
            
            // load channel name and message id
            guard let channelName = callPayload.channelName,
                  let messageId = callPayload.messageId
            else { return }
            
            Task {
                let recording = await startCallRecordingApi.startCallRecording(channelName: channelName, messageId: messageId)
                
                // Dispatch the UI update to the main thread
                DispatchQueue.main.async {
                    self.callRecording = recording
                }
            }
        }
        
    }
    
    func stopCallRecording() {
        
        guard let callPayload = currentCall?.callPayload,
              let channelName = callPayload.channelName,
              let messageId = callPayload.messageId,
              let recording  = callRecording  else { return }
        
        if !stopCallRecordingApi.isLoading {
            Task {
                await stopCallRecordingApi.stopCallRecording(channelName: channelName, messageId: messageId, callRecordingDetails: recording)
                callRecording = nil
            }
        }
        
    }
}
