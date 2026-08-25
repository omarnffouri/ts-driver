//
//  NativeCallingEventChannel.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//

import Flutter
import UIKit

public class NativeCallingEventChannel: NSObject, FlutterStreamHandler {
    
    static var shared: NativeCallingEventChannel  = NativeCallingEventChannel()
    
    var eventSink: FlutterEventSink?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterEventChannel(name: "native_calling_event_channel", binaryMessenger: registrar.messenger())
        channel.setStreamHandler(NativeCallingEventChannel.shared)
    }
    
    public func onListen(withArguments arguments: Any?, eventSink sink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = sink
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
    
    public func sendEvent(event : NativeCallingEvents,data : Any) {
        guard let sink = eventSink else { return }
        sink([
            "event" : event.getName(),
            "data" : data
        ])
    }
}

