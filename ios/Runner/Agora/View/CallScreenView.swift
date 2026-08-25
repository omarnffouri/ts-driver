//
//  CallScreenView.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//


import SwiftUI
import AVFoundation

struct CallScreenView: View {

    @Environment(\.presentationMode) var presentationMode

    @ObservedObject var agoraManager: AgoraManager = AgoraManager.shared

    @State private var didStartIncomingGate = false
    @State private var showPermissionRationale = false


    var body: some View {
        
        
        ZStack{
            
            //
            // background image
            Image("chat_background_cover")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipped()
                .opacity(0.5)
                .edgesIgnoringSafeArea(.all)
                .frame(maxWidth: UIScreen.main.bounds.width,
                                       maxHeight: UIScreen.main.bounds.height)

            //
            // call screen
            if agoraManager.currentCall?.callPayload.callType == "video"{
                if agoraManager.currentCall?.callPayload.conversationType == "oto"{
                    OneToOneVideoCallView()
                }
                else{
                    GroupVideoCallView()
                }
            }
            else{
                if agoraManager.currentCall?.callPayload.conversationType == "oto"{
                    OneToOneAudioCallView()
                        .padding(.top)
                }
                else{
                    GroupAudioCallView()
                        .padding(.top)
                }
            }
        }
        .background(Color.black)
        .onAppear { startIncomingPermissionGateIfNeeded() }
        .alert(isPresented: $showPermissionRationale) {
            Alert(
                title: Text("Permission needed"),
                message: Text(
                    isVideoCall
                        ? "Allow microphone and camera to take this video call. Without the camera the call continues with audio only."
                        : "Allow microphone access to take this call."
                ),
                primaryButton: .default(Text("Continue")) { requestCallPermissions() },
                secondaryButton: .cancel(Text("Decline")) { endForMissingPermission() }
            )
        }
        .onChange(of: agoraManager.currentCall) { newValue in
            if(newValue == nil){
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }

    private var isVideoCall: Bool {
        agoraManager.currentCall?.callPayload.callType == "video"
    }

    // Incoming gates mic/camera here before joining; outgoing already gated in Dart (no-op).
    private func startIncomingPermissionGateIfNeeded() {
        guard agoraManager.pendingIncomingJoin, !didStartIncomingGate else { return }
        didStartIncomingGate = true

        let micGranted = AVAudioSession.sharedInstance().recordPermission == .granted
        let cameraGranted = AVCaptureDevice.authorizationStatus(for: .video) == .authorized
        if micGranted && (!isVideoCall || cameraGranted) {
            agoraManager.joinAcceptedCall(cameraGranted: cameraGranted)
        } else {
            showPermissionRationale = true
        }
    }

    private func requestCallPermissions() {
        AVAudioSession.sharedInstance().requestRecordPermission { micGranted in
            if !micGranted {
                DispatchQueue.main.async { self.endForMissingPermission() }
                return
            }
            if self.isVideoCall {
                AVCaptureDevice.requestAccess(for: .video) { cameraGranted in
                    DispatchQueue.main.async {
                        self.agoraManager.joinAcceptedCall(cameraGranted: cameraGranted)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.agoraManager.joinAcceptedCall(cameraGranted: false)
                }
            }
        }
    }

    private func endForMissingPermission() {
        // Decline (hits call-declined API): no "accepted" was emitted without the mic.
        if let payload = agoraManager.currentCall?.callPayload {
            CallEventHelper.callRejected(payload: payload)
        }
        CallManager.shared.endCall(callUuid: agoraManager.currentCall?.uuid)
    }
}

