//
//  OneToOneAudioCallView.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//

import SwiftUI

struct OneToOneAudioCallView : View {
    
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
        
        let callUser = agoraManager.callUsers.first
        
        let otherUser = getOtherUser()
        
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
            //
            // user image
            AsyncImage(url: URL(string: (callUser?.participant ?? otherUser)?.image ?? "")) { phase in
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
            }.overlay{
                HStack(spacing: 0){
                    Spacer()
                    VStack(spacing:0){
                        Spacer()
                        
                        //
                        // mute icon
                        if callUser?.micMuted ?? false {
                            Image(systemName: "microphone.slash.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 25, height: 25)
                                .foregroundColor(.red)
                                .padding(10)
                                .background(Circle().fill(Color.black))
                        }
                    }
                }
            }

            //
            // user name
            Text((callUser?.participant ?? otherUser)?.name ?? "")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .padding(.top,20)

            //
            // call time view
            if agoraManager.callState == .connected {
                CallTimeView()
                    .padding(.top,20)
            }
            else{
                Text(agoraManager.callState.getName())
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 20)
            }
            
            Spacer()

            //
            // call controls view
            CallControlsView()
                .padding(.bottom)
        }
    }
    
   private func getOtherUser() -> ParticipantModel? {
       return agoraManager.participants.first { $0.pid != agoraManager.myPid && $0.pid != nil }
    }
}

