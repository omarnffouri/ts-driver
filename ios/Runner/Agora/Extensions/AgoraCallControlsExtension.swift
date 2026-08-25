//
//  AgoraCallControlsExtension.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//


extension AgoraManager {
    
    
    func toggleAudioMute()  {
        print("toggle mute audio called")
        audioMuted.toggle()
        self.agoraEngine?.muteLocalAudioStream(audioMuted)
        
    }
    

    func toggleVideoMute() {
        print("toggle mute video called")
        videoMuted.toggle()
        self.agoraEngine?.muteLocalVideoStream(videoMuted)
        if videoMuted {
            self.agoraEngine?.stopPreview()
        }
        else {
            self.agoraEngine?.startPreview()
        }
    }
    
    func toggleSpeaker() {
        print("toggle speaker called")
        speakerEnabled.toggle()
        self.agoraEngine?.setEnableSpeakerphone(speakerEnabled)
    }
    
    func toggleCamera() {
        print("toggle camera called")
        self.agoraEngine?.switchCamera()
    }
    
}
