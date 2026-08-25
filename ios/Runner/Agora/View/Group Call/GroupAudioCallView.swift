//
//  GroupAudioCallView.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//

import SwiftUI

struct GroupAudioCallView : View {
    
    @ObservedObject var agoraManager: AgoraManager = AgoraManager.shared
    
    @Environment(\.presentationMode) var presentationMode
    
    let defaultUserImage : some View = Image(systemName: "person.fill")
        .resizable()
        .scaledToFit()
        .frame(width: 100, height: 100)
        .foregroundColor(.gray)
        .padding(20)
        .overlay(Circle().stroke(.gray, lineWidth: 2))
    
    var body: some View {
        
        let currentCall : Call? = agoraManager.currentCall
        
        VStack {
            
            //
            // back button
            HStack{
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.left") // You can use a custom icon here
                        .foregroundColor(.white)
                        .padding()
                }
                Spacer()
            }
            .padding(.top)
            
            //
            // group image
            AsyncImage(url: URL(string: agoraManager.groupSettings?.logo ?? "")) { phase in
                switch phase {
                    
                case .empty:
                    defaultUserImage
                    
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 140, height: 140)
                        .clipShape(Circle())
                    
                case .failure:
                    defaultUserImage
                    
                @unknown default:
                    defaultUserImage
                }
            }
            
            //
            // group name
            Text(currentCall?.callPayload.callerName ?? "Group Audio Call")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
            
            //
            // call time view
            if agoraManager.callState == .connected {
                CallTimeView()
                    .padding(.top, 8)
                    .onAppear{
                        if !agoraManager.speakerEnabled{
                            agoraManager.toggleSpeaker()
                        }
                    }
            }
            else{
                Text(agoraManager.callState.getName())
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 8)
            }
            
            //
            // call users list
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    ForEach(agoraManager.callUsers, id: \.self) { item in
                        UserItemView(user: item)
                    }
                }
                .padding(.horizontal)
            }
            
            //
            // call controls view
            CallControlsView()
                .padding(.bottom)
        }
        
    }
}

private struct UserItemView : View {
    @ObservedObject var user: CallUser
    @State var userName: String = ""
    
    init(user: CallUser) {
        self.user = user
        userName = user.participant?.name ?? ""
    }
    
    var body: some View {
        
        
        VStack{
            
            HStack(spacing : 5){
                
                Spacer()

                // mic muted
                if user.micMuted {
                    Image(systemName: "microphone.slash.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 18, height: 18)
                        .foregroundColor(.red)
                        .padding(8)
                        .background(Circle().fill(Color.white))
                }
                // active speaker icon
                else if user.isSpeaking {
                    Image(systemName: "speaker.wave.2.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 18, height: 18)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Circle().fill(Color.black))
                }
            }
            
            Spacer()
            
            Text(user.participant?.name ?? "")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(2)
                .frame(maxWidth: .infinity)
            
            Text(user.participant?.userDesignation ?? "")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
        }
        .padding(10)
        .frame(height: 220)
        .background(
            AsyncImage(url: URL(string: user.participant?.image ?? "")) { phase in
                switch phase {
                    
                case .empty:
                    Color.gray
                    
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .background(Color.gray)
                    
                case .failure:
                    Color.gray
                    
                @unknown default:
                    Color.gray
                }
            }.overlay{
                LinearGradient(
                    gradient: Gradient(
                        colors: [
                            Color.black.opacity(0.7),
                            Color.black.opacity(0.6),
                            Color.black.opacity(0.5),
                            Color.black.opacity(0.4),
                            Color.black.opacity(0.3),
                            Color.black.opacity(0.2),
                            Color.black.opacity(0.1),
                        ]
                    ),
                    startPoint: .bottom,
                    endPoint: .center
                )
            }
        )
        .cornerRadius(15)
    }
}
