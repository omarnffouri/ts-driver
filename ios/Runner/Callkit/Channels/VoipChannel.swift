//
//  VoipChannel.swift
//  Runner
//
//  Created by TMS on 24/01/2024.
//

import Foundation
import Flutter

public class VoipChannel: NSObject, FlutterPlugin {

    public static var  channel : FlutterMethodChannel? ;

    public static func register(with registrar: FlutterPluginRegistrar) {
         channel = FlutterMethodChannel(name: "voipChannel", binaryMessenger: registrar.messenger())
        let instance = VoipChannel()
        registrar.addMethodCallDelegate(instance, channel: channel!)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getVoipToken":
            result(PushKitManager.shared.getVoipToken())
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
