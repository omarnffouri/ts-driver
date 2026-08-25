//
//  AgoraReseterExtension.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//

extension AgoraManager {
    
    
    func resetAgoraManager() {
        pendingIncomingJoin = false
        clearDataVariables()
        resetCallStates()
        resetCallTime()
    }
    
    func resetCallTime() {
        self.callTimer?.invalidate()
        self.callTimer = nil
        self.hours = 0
        self.minutes = 0
        self.seconds = 0
        self.totalTicks = 0
    }
    
    private func clearDataVariables() {
        self.currentCall = nil
        self.groupSettings = nil
        self.myPid = nil
        self.selectedCallUser = nil
        self.callRecording = nil
        self.participants.removeAll()
        self.callUsers.removeAll()
    }
    
    
    private func resetCallStates() {
        self.audioMuted = false
        self.videoMuted = false
        self.speakerEnabled = false
        self.localUserJoined = false
        self.remoteUserJoined = false
        self.callState = .idle
    }
    

    
}
