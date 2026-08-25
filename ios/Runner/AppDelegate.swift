import UIKit
import FirebaseCore
import Flutter
import FirebaseMessaging
import GoogleMaps
import flutter_downloader
import CoreLocation
import PushKit

@main
@objc class AppDelegate: FlutterAppDelegate , MessagingDelegate{
    let locationManager = CLLocationManager()
    
    
    override func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?
    )-> Bool {
        
        
        //
        // setting up location service when app launched for location event
        if let options = launchOptions, options[.location] != nil {
            LocationService.shared.setupLocationServiceOnAppRelaunch();
        }
        
        
        return true;
    }
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        GMSServices.provideAPIKey("REPLACE_WITH_GOOGLE_API_KEY")
        
        // configuring notifications deligate
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }
        
        GeneratedPluginRegistrant.register(with: self)
        
        // flutter downloader configs
        FlutterDownloaderPlugin.setPluginRegistrantCallback { registry in
            if(!registry.hasPlugin("FlutterDownloaderPlugin")){
                FlutterDownloaderPlugin.register(with: registry.registrar(forPlugin: "FlutterDownloaderPlugin")!)
            }
        }
        
        
        // Register the method channels
        if let controller = window?.rootViewController as? FlutterViewController {
            
            // clipboard channel
            let clipBoardChannel = FlutterMethodChannel(
                name: "clipboardChannel",
                binaryMessenger: controller.binaryMessenger
            )
            
            // registering a method call handler for clipboard channel
            clipBoardChannel.setMethodCallHandler { [weak self] (call, result) in
                self?.clipboardHandleMethodCall(call, result: result)
            }
              
        }
        
        
        //
        // creating and configuring location service channel
        LocationChannel.register(with: registrar(forPlugin: "LocationChannel")!)
        
        
        //
        // creating and configuring native calling channels
        NativeCallingMethodChannel.register(with: registrar(forPlugin: "NativeCallingMethodChannel")!)
        NativeCallingEventChannel.register(with: registrar(forPlugin: "NativeCallingEventChannel")!)
        
        
        //
        // setting up location service when app launched for location event
        if let options = launchOptions, options[.location] != nil {
            LocationService.shared.setupLocationServiceOnAppRelaunch();
        }
        
        
        //
        // Setup VOIP
        PushKitManager.shared.registerForVoipPushes();
        
        
        //
        // creating and configuring the voip channel
        VoipChannel.register(with: registrar(forPlugin: "VoipChannel")!)
        
        
        //
        // register a puhser manager
        PusherManager.shared.initializePusher()
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func applicationDidEnterBackground(_ application: UIApplication) {
        LocationService.shared.appEnterBackground()
    }
    
    override func applicationWillEnterForeground(_ application: UIApplication) {
        LocationService.shared.appEnterForeground()
    }
    
    
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        // Here you can send the FCM token to your server or perform any other actions.
        
    }
    
    
    
    // Add this method for background message handling
    override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                              fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        // print(userInfo);
        
        // Handle your background message here
        if(userInfo["notification_type"] as? String == "call"){
            
            let channelName =  userInfo["channelName"]
            let conversationId = userInfo["conversationId"]
            let messageId = userInfo["messageId"]
            let conversationType = userInfo["conversationType"]
            let callType = userInfo["callType"]
            let callerId = userInfo["caller_id"]
            let callerModelType = userInfo["caller_model_type"]
            let callerName = userInfo["caller_name"]
            let callerImage = userInfo["caller_image"]
            let callPlacedAt = userInfo["call_placed_at"]
            let tempCallId = userInfo["temp_call_id"] ?? UUID().uuidString
            let incomingDeclined : Bool = CallPayload.boolFlag(userInfo["incomming_declined"])
            
            let data : [String : Any ] = [
                "channelName":channelName ?? "",
                "conversationId":conversationId ?? 0,
                "messageId":messageId ?? 0,
                "conversationType":conversationType ?? "oto",
                "callType":callType ?? "",
                "caller_id":callerId ?? 0,
                "caller_model_type":callerModelType ?? "",
                "caller_name":callerName ?? "",
                "caller_image" : callerImage ?? "",
                "call_placed_at" : callPlacedAt ?? 0,
                "incomming_declined" : incomingDeclined,
                "temp_call_id":tempCallId
            ]
                        
            let callUuid = UUID(uuidString: (tempCallId as? String) ?? "") ?? UUID()

            if(incomingDeclined){
                // FCM data values arrive as strings; fall back to matching by conversation
                var conversationIdValue : Int? = conversationId as? Int
                if conversationIdValue == nil, let conversationIdString = conversationId as? String {
                    conversationIdValue = Int(conversationIdString)
                }

                CallManager.shared.declineIncomingCall(callUuid: callUuid, conversationId: conversationIdValue)
                showMisscallNotification(title: "Missed Call", body: "You have a missed call from \(callerName ?? "").")
            }
        }
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    
    
    private func clipboardHandleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getImageFromClipboard":
            if let image = ClipboardManager.getFileFromClipboard() {
                if let imageData = image.pngData() {
                    result(FlutterStandardTypedData(bytes: imageData))
                } else {
                    result(nil)
                }
            } else {
                result(nil)
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    
    private func registerPlugin(registry : FlutterPluginRegistry){
        if(!registry.hasPlugin("FlutterDownloaderPlugin")){
            FlutterDownloaderPlugin.register(with: registry.registrar(forPlugin: "FlutterDownloaderPlugin")!)
        }
    }
    
    
    private func showMisscallNotification(title : String , body : String){
        
        /// Request permission to show notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                // Notification content
                let content = UNMutableNotificationContent()
                content.title = title
                content.body = body
                content.sound = UNNotificationSound.default
                
                // Set up the trigger for the notification (e.g., display it after 5 seconds)
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                
                // Create the notification request
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                
                // Schedule the notification
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("Error scheduling notification: \(error.localizedDescription)")
                    } else {
                        print("Missed call notification scheduled successfully.")
                    }
                }
            } else if let error = error {
                
            }
        }
    }
    
    
}


public class ClipboardManager: NSObject {
    static func getFileFromClipboard() -> UIImage? {
        let pasteboard = UIPasteboard.general
        if let image = pasteboard.image {
            return image
        } else {
            return nil
        }
    }
}


extension Date {
    
    
    static func fromMillisecondsString(_ millisecondsString: String) -> Date? {
        // Convert milliseconds string to TimeInterval (Double)
        guard let milliseconds = Double(millisecondsString) else {
            return nil
        }
        
        // Convert milliseconds to seconds
        let seconds = milliseconds / 1000.0
        
        // Create Date object from TimeInterval
        return Date(timeIntervalSince1970: seconds)
    }
    
    
    static func differenceInSecondsFromMilliseconds(_ milliseconds: Double) -> Int {
        // Convert milliseconds string to TimeInterval (Double)
//        guard let milliseconds = Double(millisecondsString) else {
//            return nil
//        }
        
        if milliseconds == 0 {
            return 0
        }
        
        // Convert milliseconds to seconds
        let seconds = milliseconds / 1000.0
        
        // Create Date object from TimeInterval
        let utcDate = Date(timeIntervalSince1970: seconds)
        
        // Get current UTC Date
        let currentDate = Date()
        
        // Calculate difference in seconds
        let differenceInSeconds = Int(currentDate.timeIntervalSince(utcDate))
        
        return differenceInSeconds
    }
    
}
