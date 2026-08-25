//
//  GroupVideoCallView.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//

import SwiftUI

struct GroupVideoCallView : View {
    
    @ObservedObject var agoraManager: AgoraManager = AgoraManager.shared
    
    @Environment(\.presentationMode) var presentationMode
    
    
    //
    //  positions
    @State private var horizontalUserListPosition: CGPoint = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 350)
    @State private var closeButtonPosition: CGPoint = CGPoint(x: UIScreen.main.bounds.width - 50, y: 150)
    
    @State private var showingControls: Bool = true
    @State private var controlsOffset: CGFloat = 0
    
    
    //
    // y top values
    private let minTopY: CGFloat = 150
    private let maxTopY: CGFloat = 70
    
    //
    // y bottom values
    private let minBottomY: CGFloat = UIScreen.main.bounds.height - 350
    private let maxBottomY: CGFloat = UIScreen.main.bounds.height - 240
    
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
    
    let defaultUserImage : some View = Image(systemName: "person.fill")
        .resizable()
        .scaledToFit()
        .frame(width: 36, height: 36)
        .foregroundColor(.gray)
        .padding(8)
        .overlay(Circle().stroke(.gray, lineWidth: 2))
    
    var body: some View {
        
        let currentCall : Call? = agoraManager.currentCall
        
        ZStack {
            
            
            //
            //
            // selected user video view
            if agoraManager.selectedCallUser != nil {
                
                //
                // selected user video view
                AgoraDynamicVideoView(agoraManager: agoraManager, uid:  agoraManager.selectedCallUser!.remoteId)
                    .frame(width: UIScreen.main.bounds.width, height:UIScreen.main.bounds.height)
                    .blur(radius: agoraManager.selectedCallUser!.videoMuted ? 10 : 0)
                    .clipped()
                    .overlay{
                        ZStack{
                            
                            Button(action: {
                                agoraManager.callUsers.insert(agoraManager.selectedCallUser!, at: 0)
                                agoraManager.selectedCallUser = nil
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(.red)
                                    .padding(4)
                                    .background(Circle().fill(Color.white))
                            }
                            .position(closeButtonPosition)
                            .animation(.easeInOut, value: closeButtonPosition)
                            
                            HStack(spacing: 10){
                                
                                if (agoraManager.selectedCallUser!.videoMuted) {
                                    Image(systemName: "video.slash.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 25, height: 25)
                                        .foregroundColor(.white)
                                    
                                }
                                
                                if (agoraManager.selectedCallUser!.micMuted) {
                                    Image(systemName: "microphone.slash.circle.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 25, height: 25)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                    .onTapGesture {
                        handleControlsOffset()
                    }
                    .onDisappear{
                        if !showingControls{
                            handleControlsOffset()
                        }
                    }
                    .onAppear{
                        if showingControls{
                            handleControlsOffset()
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
                    // group image
                    AsyncImage(url: URL(string: agoraManager.groupSettings?.logo ?? "")) { phase in
                        switch phase {
                            
                        case .empty:
                            defaultUserImage
                            
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 52, height: 52)
                                .clipShape(Circle())
                            
                        case .failure:
                            defaultUserImage
                            
                        @unknown default:
                            defaultUserImage
                        }
                    }.padding(.trailing)
                    
                    //
                    // group name and call state and call time
                    VStack (alignment: .leading){
                        
                        //
                        // group name
                        Text(currentCall?.callPayload.callerName ?? "Group Audio Call")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity)
                        
                        //
                        // call time view and call status
                        if agoraManager.callState == .connected {
                            CallTimeView()
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
                        }
                    }
                    .padding(.trailing, 30)
                    
                }
                .padding(.vertical,8)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.black))
                .padding(.horizontal,20)
                .shadow(radius: 10)
                .offset(y: -controlsOffset)
                .animation(.easeInOut, value: -controlsOffset)
                
                //
                //
                // video views list
                if agoraManager.selectedCallUser == nil{
                    
                    //
                    // local video view
                    AgoraStaticVideoView(agoraManager: agoraManager, uid:  0)
                        .frame( height: 230)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .blur(radius: agoraManager.videoMuted ? 10 : 0)
                        .clipped()
                        .overlay{
                            ZStack{
                                
                                HStack(spacing: 10){
                                    
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
                                
                                RoundedRectangle(cornerRadius: 10).stroke(Color.white, lineWidth: 2)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom,10)
                    
                    
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 20) {
                            ForEach(agoraManager.callUsers, id: \.self) { user in
                                UserGridItemView(user: user)
                            }
                        }
                        .padding(.horizontal)
                        
                    }
                }
                else{
                    Spacer()
                    
                    HStack{
                        
                        //
                        // local video view
                        AgoraStaticVideoView(agoraManager: agoraManager, uid:  0)
                            .frame(width:100, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .blur(radius: agoraManager.videoMuted ? 10 : 0)
                            .clipped()
                            .overlay{
                                ZStack{
                                    
                                    HStack(spacing: 5){
                                        
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
                                    
                                    
                                    RoundedRectangle(cornerRadius: 10).stroke(Color.white, lineWidth: 2)
                                }
                            }
                            .padding(.trailing , 10)
                            .padding(.leading)
                        
                        
                        
                        //
                        // other users list
                        ScrollView(.horizontal) {
                            LazyHStack(spacing: 10) {
                                ForEach(agoraManager.callUsers, id: \.remoteId) { user in
                                    UserListItemView(user: user)
                                        .padding(.trailing)
                                        .id(UUID())
                                }
                            }
                        }
                        .frame(maxHeight: 160)
                        
                    }
                    .position(horizontalUserListPosition)
                    .animation(.easeInOut, value: horizontalUserListPosition)
                }
                
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
    
    
    private func handleControlsOffset()  {
        withAnimation {
            if showingControls {
                controlsOffset = 300
                showingControls = false
                
                horizontalUserListPosition.y = maxY
                closeButtonPosition.y = minY
                
            }
            else{
                controlsOffset = 0
                showingControls = true
                
                if horizontalUserListPosition.y > maxY {
                    horizontalUserListPosition.y = maxY
                }
                
                if closeButtonPosition.y < minY {
                    closeButtonPosition.y = minY
                }
            }
        }
    }
}


private struct UserGridItemView : View {
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
                
                if user.videoMuted {
                    Image(systemName: "video.slash.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 18, height: 18)
                        .foregroundColor(.red)
                        .padding(8)
                        .background(Circle().fill(Color.white))
                }
                
            }
            .padding(.trailing,10)
            .padding(.top,10)
            
            Spacer()
            
            Text(user.participant?.name ?? "")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(2)
                .frame(maxWidth: .infinity)
                .padding(.leading)
                .padding(.trailing)
            
            Text(user.participant?.userDesignation ?? "")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .padding(.leading)
                .padding(.trailing)
                .padding(.bottom)
        }
        .frame(height: 270)
        .background(
            AgoraStaticVideoView(agoraManager: AgoraManager.shared,uid: user.remoteId)
                .blur(radius: user.videoMuted ? 10 : 0)
                .clipped()
                .overlay{
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
        .overlay{
            RoundedRectangle(cornerRadius: 15).stroke(Color.white, lineWidth: 2)
        }
        .onTapGesture {
            withAnimation{
                let agora = AgoraManager.shared
                if agora.selectedCallUser != nil {
                    agora.callUsers.insert(agora.selectedCallUser!, at : 0)
                }
                agora.selectedCallUser = user
                agora.callUsers.removeAll { $0.remoteId == user.remoteId }
            }
        }
        
    }
}



private struct UserListItemView : View {
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
                        .frame(width: 16, height: 16)
                        .foregroundColor(.red)
                        .padding(4)
                        .background(Circle().fill(Color.white))
                }
                // active speaker icon
                else if user.isSpeaking {
                    Image(systemName: "speaker.wave.2.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16, height: 16)
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Circle().fill(Color.black))
                }
                
                if user.videoMuted {
                    Image(systemName: "video.slash.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16, height: 16)
                        .foregroundColor(.red)
                        .padding(4)
                        .background(Circle().fill(Color.white))
                }
                
            }
            .padding(.trailing,5)
            .padding(.top,5)
            
            Spacer()
            
            Text(user.participant?.name ?? "")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.white)
                .lineLimit(2)
                .frame(maxWidth: .infinity)
                .padding(.leading)
                .padding(.trailing)
            
            Text(user.participant?.userDesignation ?? "")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.white)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .padding(.leading)
                .padding(.trailing)
                .padding(.bottom)
        }
        .frame(width: 100,height: 150)
        .background(
            AgoraStaticVideoView(agoraManager: AgoraManager.shared,uid: user.remoteId)
                .blur(radius: user.videoMuted ? 10 : 0)
                .clipped()
                .overlay{
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
        .cornerRadius(10)
        .overlay{
            RoundedRectangle(cornerRadius: 10).stroke(Color.white, lineWidth: 2)
        }
        .onTapGesture {
            withAnimation{
                let agora = AgoraManager.shared
                if agora.selectedCallUser != nil {
                    agora.callUsers.insert(agora.selectedCallUser!, at : 0)
                }
                agora.selectedCallUser = user
                agora.callUsers.removeAll { $0.remoteId == user.remoteId }
            }
        }
        
    }
}


