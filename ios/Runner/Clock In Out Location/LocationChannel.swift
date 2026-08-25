//
//  LocationChannel.swift
//  Runner
//
//  Created by TMS on 11/12/2023.
//

import Foundation
import Flutter

public class LocationChannel: NSObject, FlutterPlugin {

    public static var  channel : FlutterMethodChannel? ;

    public static func register(with registrar: FlutterPluginRegistrar) {
         channel = FlutterMethodChannel(name: "locationServiceChannel", binaryMessenger: registrar.messenger())
        let instance = LocationChannel()
        registrar.addMethodCallDelegate(instance, channel: channel!)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startLocationService":
            LocationService.shared.startLocationService()
            result(nil)
        case "stopLocationService":
            LocationService.shared.stopLocationService()
            result(nil)
        case "isServiceRunning":
            let isRunning = LocationService.shared.isServiceRunning()
            result(isRunning)
        case "hasLocationAlwaysPermission": LocationService.shared.hasLocationAlwaysPermission{
                hasPermission in
            result(hasPermission)
            }
            
        case "requestForAlwaysLocationPermission":
            LocationService.shared.requestForAlwaysLocationPermission()
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
