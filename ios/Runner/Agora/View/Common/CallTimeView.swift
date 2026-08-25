//
//  CallTimeView.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//

import SwiftUI

struct CallTimeView : View {
    
    @ObservedObject var agoraManager: AgoraManager = AgoraManager.shared
    
    var body: some View {

        HStack(spacing: 0){

            //
            // hours view
            if agoraManager.hours > 0{
                
                if agoraManager.hours < 10 {
                    Text("0")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .padding(0)
                }
                
                Text("\(agoraManager.hours) : ")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .padding(0)
            }

            //
            // minutes view
            if agoraManager.minutes < 10 {
                Text("0")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .padding(0)
            }
            
            Text("\(agoraManager.minutes) : ")
                .font(.system(size: 14))
                .foregroundColor(.white)
                .padding(0)
            
            //
            // seconds view
            if agoraManager.seconds < 10 {
                Text("0")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .padding(0)
            }
            
            Text("\(agoraManager.seconds)")
                .font(.system(size: 14))
                .foregroundColor(.white)
                .padding(0)
            
        }
    }
}
