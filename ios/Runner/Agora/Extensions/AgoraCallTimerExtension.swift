//
//  AgoraCallTimer.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//

extension AgoraManager {
    
    
    func startCallTimer() {
        guard callTimer == nil else { return }
        resetCallTime()
        callTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    @objc private func updateTime() {
        guard let startTime = currentCall?.connectedDate else { return }
        
        // Calculate the time difference from the start
        let elapsedTime = Date().timeIntervalSince(startTime)
        
        // Update total ticks (seconds)
        totalTicks = Int(elapsedTime)
        
        // Convert seconds into hours, minutes, and seconds
        hours = totalTicks / 3600
        minutes = (totalTicks % 3600) / 60
        seconds = totalTicks % 60
        
        NativeCallingEventChannel.shared.sendEvent(event: .callTime, data: [
            "hours" : hours,
            "minutes" : minutes,
            "seconds" : seconds
        ])
        
        // Print or store the time if needed
        print("Time Elapsed: \(hours) hours, \(minutes) minutes, \(seconds) seconds")
    }
    

    func stopCallTimer() {
        callTimer?.invalidate()  // Invalidate the timer
        callTimer = nil
        print("Final Time: \(hours) hours, \(minutes) minutes, \(seconds) seconds")
    }
    
    
}
