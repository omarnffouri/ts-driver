//
//  NativeCallingMethodChannel.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//

import Foundation
import Flutter
import SwiftUI

public class NativeCallingMethodChannel: NSObject, FlutterPlugin {
    
    public static var  channel : FlutterMethodChannel?;
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        channel = FlutterMethodChannel(name: "native_calling_method_channel", binaryMessenger: registrar.messenger())
        let instance = NativeCallingMethodChannel()
        registrar.addMethodCallDelegate(instance, channel: channel!)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
            
        case "place_call":
            
            guard let arguments = call.arguments as? [String: Any],
                  let callPayload = CallPayload.fromDictionary(dictionary: NSDictionary(dictionary: arguments)),
                  let tempCallID =  UUID(uuidString: callPayload.tempCallId) else {
                result(false)
                return
            }
            
            CallManager.shared.placeOutgoingCall(call: Call(uuid: tempCallID, callPayload: callPayload, isOutGoing: true)) { success in
                result(success)
            }
            
            break;
            
            
        case "open_native_call_ui":
            
            guard let callID = call.arguments as? String,
                  let currentCall = AgoraManager.shared.currentCall else {
                result(false)
                return
            }
            
            if(currentCall.callPayload.tempCallId == callID){
                openFullScreenView()
                result(true)
            }
            else{
                result(false)
            }
            break;
            
            
        case "end_call":
            
            guard let callID = call.arguments as? String,
                  let currentCall = AgoraManager.shared.currentCall else {
                result(false)
                return
            }
            
            if(currentCall.callPayload.tempCallId == callID){
                AgoraManager.shared.endCall()
                result(true)
            }
            else{
                result(false)
            }
            break;
            
            
        case "can_start_call":
            result(CallManager.shared.currentCall == nil)
            break;
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    
    private func openFullScreenView() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let window = windowScene.windows.first {
                let rootView = CallScreenView() // Your SwiftUI view for the call screen
                let hostingController = UIHostingController(rootView: rootView)
                hostingController.modalPresentationStyle = .fullScreen
                window.rootViewController?.present(hostingController, animated: true, completion: nil)
            }
        }
    }
}
