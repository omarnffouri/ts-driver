//
//  IntruptionNotificationHelper.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//


import AVFoundation
import NotificationCenter

class InterruptionNotificationManager {
    
    static let shared = InterruptionNotificationManager()
    
    
    // When your app is about to start using the audio session, post the interruption start notification
    func sendAudioInterruptionStartNotification() {
        var userInfo: [AnyHashable: Any] = [:]
        let interruptionStartRaw = AVAudioSession.InterruptionType.began.rawValue
        userInfo[AVAudioSessionInterruptionTypeKey] = interruptionStartRaw
        NotificationCenter.default.post(name: AVAudioSession.interruptionNotification, object: self, userInfo: userInfo)
    }

    // This function should be called when your app has activated the audio session (accepted the call)
    func sendAudioInterruptionEndNotification() {
        var userInfo: [AnyHashable: Any] = [:]
        let interruptionEndRaw = AVAudioSession.InterruptionType.ended.rawValue
        userInfo[AVAudioSessionInterruptionTypeKey] = interruptionEndRaw
        userInfo[AVAudioSessionInterruptionOptionKey] = AVAudioSession.InterruptionOptions.shouldResume.rawValue
        NotificationCenter.default.post(name: AVAudioSession.interruptionNotification, object: self, userInfo: userInfo)
    }
}
