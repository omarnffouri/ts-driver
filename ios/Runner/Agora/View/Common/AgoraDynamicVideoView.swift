//
//  AgoraDynamicVideoView.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//

import SwiftUI

struct AgoraDynamicVideoView: UIViewRepresentable {
    let agoraManager: AgoraManager
    let uid : Int
    
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        if(uid <= 0){
            agoraManager.setupLocalVideo(view: view)
        }
        else{
            agoraManager.removeRemoteVideo(uid: UInt(uid))
            agoraManager.setupRemoteVideo(uid: UInt(uid), view : view)
        }
        return view 
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if(uid <= 0){
            agoraManager.setupLocalVideo(view: uiView)
        }
        else{
            agoraManager.removeRemoteVideo(uid: UInt(uid))
            agoraManager.setupRemoteVideo(uid: UInt(uid), view : uiView)
        }
    }
}
