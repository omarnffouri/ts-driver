//
//  CallControlsView.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//

import SwiftUI

struct CallControlsView : View{
    
    @ObservedObject var agoraManager: AgoraManager = AgoraManager.shared
    
    var body : some View{
        
        if agoraManager.callState != .failed {
            
            HStack{

                Spacer()
                
                // Speaker Button
                Button(action: {
                    agoraManager.toggleSpeaker()
                }) {
                    Image(systemName: agoraManager.speakerEnabled ? "speaker.3.fill" : "speaker.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25)
                        .foregroundColor(agoraManager.speakerEnabled ? .red : .white)
                        .padding()
                        .background(Circle().fill( agoraManager.speakerEnabled ? Color.white : Color.gray.opacity(0.5)))
                }
 
                // Switch Camera Button
                if agoraManager.currentCall?.callPayload.callType == "video"{
                    
                    Spacer()
                    
                    Button(action: {
                        agoraManager.toggleCamera()
                    }) {
                        Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90.camera.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25)
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Color.gray.opacity(0.5)))
                    }
 
                    Spacer()
                    
                    // Mute Video Button
                    Button(action: {
                        agoraManager.toggleVideoMute()
                    }) {
                        Image(systemName: agoraManager.videoMuted ? "video.slash.fill" : "video.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25)
                            .foregroundColor(agoraManager.videoMuted ? .red : .white)
                            .padding()
                            .background(Circle().fill( agoraManager.videoMuted ? Color.white : Color.gray.opacity(0.5)))
                    }
                }

                Spacer()
                
                // Mute Audio Button
                Button(action: {
                    agoraManager.toggleAudioMute()
                }) {
                    Image(systemName: agoraManager.audioMuted ? "mic.slash.fill" : "mic.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25)
                        .foregroundColor(agoraManager.audioMuted ? .red : .white)
                        .padding()
                        .background(Circle().fill( agoraManager.audioMuted ? Color.white : Color.gray.opacity(0.5)))
                }
                
                Spacer()

                // End call Button
                Button(action: {
                    agoraManager.endCall()
                }) {
                    Image(systemName: "phone.down.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25)
                        .foregroundColor(.white)
                        .padding()
                        .background(Circle().fill(.red))
                }
                
                Spacer()
            }
            .padding(.vertical)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.black))
        }
        else {
            EmptyView()
        }
    }
}
