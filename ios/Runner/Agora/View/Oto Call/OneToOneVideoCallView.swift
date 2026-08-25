//
//  OneToOneVideoCallView.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//

import SwiftUI

struct OneToOneVideoCallView : View {
    
    @ObservedObject var agoraManager: AgoraManager = AgoraManager.shared
    
    @Environment(\.presentationMode) var presentationMode
    
    //
    // video positions
    @State private var remoteVideoPosition: CGPoint = CGPoint(x: 70 , y: UIScreen.main.bounds.height - 230)
    @State private var localVideoPosition: CGPoint = CGPoint(x: UIScreen.main.bounds.width - 70, y: UIScreen.main.bounds.height - 230)
    @State private var centerPosition: CGPoint = CGPoint(x: UIScreen.main.bounds.width / 2 , y: UIScreen.main.bounds.height / 2)
    
    //
    // views states
    @State private var showingRemoteVideo: Bool = true
    @State private var showingControls: Bool = true
    @State private var controlsOffset: CGFloat = 0
    
    //
    // return the closest y point of remote video current poistion
    var closestRemoteYPoint: Double {
        let distanceToPoint1 = abs(remoteVideoPosition.y - minY)
        let distanceToPoint2 = abs(remoteVideoPosition.y - maxY)
        return distanceToPoint1 < distanceToPoint2 ? minY : maxY
    }
    
    
    //
    // return the closest y point of local video current poistion
    var closestLocalYPoint: Double {
        let distanceToPoint1 = abs(localVideoPosition.y - minY)
        let distanceToPoint2 = abs(localVideoPosition.y - maxY)
        return distanceToPoint1 < distanceToPoint2 ? minY : maxY
    }
    
    //
    // y top values
    private let minTopY: CGFloat = 220
    private let maxTopY: CGFloat = 150
    
    //
    // y bottom values
    private let minBottomY: CGFloat = UIScreen.main.bounds.height - 230
    private let maxBottomY: CGFloat = UIScreen.main.bounds.height - 100
    
    
    //
    // y value
    private var minY: CGFloat {
        get {
            return showingControls ? minTopY : maxTopY
        }
    }
    private var maxY: CGFloat {
        get {
            return showingControls ? minBottomY : maxBottomY
        }
    }
    
    // x value
    private let minX: CGFloat = 70
    private let maxX: CGFloat = UIScreen.main.bounds.width - 70
    
    
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
        
        ZStack {
            
            //
            // video views
            if agoraManager.callState == .connected && !agoraManager.callUsers.isEmpty {
                
                AgoraStaticVideoView(agoraManager: agoraManager, uid:  agoraManager.callUsers.first!.remoteId)
                    .frame(width: showingRemoteVideo ? UIScreen.main.bounds.width : 100,
                           height: showingRemoteVideo ? UIScreen.main.bounds.height : 150)
                    .clipShape(RoundedRectangle(cornerRadius: showingRemoteVideo ? 0 : 10))
                    .position( showingRemoteVideo ? centerPosition : remoteVideoPosition)
                    .zIndex(showingRemoteVideo ? -1 : 0)
                    .animation(.easeInOut, value: remoteVideoPosition)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if !showingRemoteVideo {
                                    let x = min(max(value.location.x, minX), maxX)
                                    let y = min(max(value.location.y, minY), maxY)
                                    remoteVideoPosition = CGPoint(x: x, y: y)
                                }
                            }
                            .onEnded { value  in
                                if !showingRemoteVideo {
                                    let x = value.location.x < UIScreen.main.bounds.width / 2 ? minX : maxX
                                    var y = value.location.y
                                    if y < minY {
                                        y = minY
                                    }
                                    else if y > maxY {
                                        y = maxY
                                    }
                                    remoteVideoPosition = CGPoint(x: x, y: y)
                                }
                            }
                    )
                    .onTapGesture {
                        withAnimation{
                            if showingRemoteVideo {
                                handleControlsOffset()
                            }
                            else{
                                showingRemoteVideo.toggle()
                            }
                        }
                    }
                    .blur(radius: (callUser?.videoMuted ?? false) ? 10 : 0)
                    .clipped()
                    .overlay{
                        HStack(spacing: showingRemoteVideo ? 10 : 5){
                            
                            if (callUser?.videoMuted ?? false) {
                                Image(systemName: "video.slash.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(.white)
                                    
                            }
                            
                            if (callUser?.micMuted ?? false) {
                                Image(systemName: "microphone.slash.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(.white)
                            }
                        }
                        .position(showingRemoteVideo ? centerPosition : remoteVideoPosition)
                    }
                
                
                AgoraStaticVideoView(agoraManager: agoraManager, uid:  0)
                    .frame(width: showingRemoteVideo ? 100 : UIScreen.main.bounds.width,
                           height: showingRemoteVideo ? 150 : UIScreen.main.bounds.height)
                    .clipShape(RoundedRectangle(cornerRadius: showingRemoteVideo ? 10 : 0))
                    .position( showingRemoteVideo ? localVideoPosition : centerPosition)
                    .zIndex(showingRemoteVideo ? 0 : -1)
                    .animation(.easeInOut, value: localVideoPosition)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if showingRemoteVideo {
                                    let x = min(max(value.location.x, minX), maxX)
                                    let y = min(max(value.location.y, minY), maxY)
                                    localVideoPosition = CGPoint(x: x, y: y)
                                }
                            }
                            .onEnded { value in
                                if showingRemoteVideo{
                                    let x = value.location.x < UIScreen.main.bounds.width / 2 ? minX : maxX
                                    var y = value.location.y
                                    if y < minY {
                                        y = minY
                                    }
                                    else if y > maxY {
                                        y = maxY
                                    }
                                    localVideoPosition = CGPoint(x: x,y: y)
                                }
                            }
                    )
                    .onTapGesture {
                        withAnimation{
                            if showingRemoteVideo {
                                showingRemoteVideo.toggle()
                            }
                            else{
                                handleControlsOffset()
                            }
                        }
                    }
                    .blur(radius: agoraManager.videoMuted ? 10 : 0)
                    .clipped()
                    .overlay{
                        HStack(spacing: !showingRemoteVideo ? 10 : 5){
                            
                            if (agoraManager.videoMuted) {
                                Image(systemName: "video.slash.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(.white)
                                    
                            }
                            
                            if (agoraManager.audioMuted) {
                                Image(systemName: "microphone.slash.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(.white)
                            }
                        }
                        .position(!showingRemoteVideo ? centerPosition : localVideoPosition)
                    }
            }
            else{
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
                        }
            }
            
            //
            //
            // controlles and other view
            VStack{

                //
                // app bar
                HStack{
                    
                    //
                    // back button
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left") // You can use a custom icon here
                            .foregroundColor(.white)
                            .padding()
                    }

                    //
                    // user name and call state
                    VStack {
                        
                        Text((callUser?.participant ?? otherUser)?.name ?? "")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity)
                        
                        
                        if agoraManager.callState == .connected {
                            CallTimeView()
                        }
                        else{
                            Text(agoraManager.callState.getName())
                                .font(.system(size: 14, weight: .bold))
                                .lineLimit(1)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.trailing, 30)
                    
                }
                .padding(.vertical)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.black))
                .padding(.horizontal,20)
                .shadow(radius: 10)
                .offset(y: -controlsOffset)
                .animation(.easeInOut, value: -controlsOffset)

                Spacer()

                //
                // call controls view
                CallControlsView()
                    .padding(.horizontal, 20)
                    .shadow(radius: 10)
                    .offset(y: controlsOffset)
                    .animation(.easeInOut, value: controlsOffset)
            }
            .padding(.vertical, 50)
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    private func getOtherUser() -> ParticipantModel? {
        return agoraManager.participants.first { $0.pid != agoraManager.myPid && $0.pid != nil }
    }
    
    private func handleControlsOffset()  {
        withAnimation {
            if showingControls {
                controlsOffset = 300
                showingControls = false
                
                if showingRemoteVideo {
                    localVideoPosition.y = closestLocalYPoint
                }
                else {
                    remoteVideoPosition.y = closestRemoteYPoint
                }
            }
            else{
                controlsOffset = 0
                showingControls = true

                //
                // adjust the local video y poistion
                if localVideoPosition.y < minY {
                    localVideoPosition.y = minY
                }
                else if localVideoPosition.y > maxY {
                    localVideoPosition.y = maxY
                }
                
                //
                // adjust the remote video y poistion
                if remoteVideoPosition.y < minY {
                    remoteVideoPosition.y = minY
                }
                else if remoteVideoPosition.y > maxY {
                    remoteVideoPosition.y = maxY
                }
            }
        }
    }
}

