//
//  PushKitManager.swift
//  Runner
//
//  Created by TMS on 24/01/2024.
//

import Foundation
import PushKit
import CallKit
//import flutter_callkit_incoming


class PushKitManager: NSObject, PKPushRegistryDelegate {
    static let shared = PushKitManager()
    
    private override init() {
        super.init()
    }
    
    private var pushRegistry: PKPushRegistry!
    
    func registerForVoipPushes() {
        pushRegistry = PKPushRegistry(queue: DispatchQueue.main)
        pushRegistry.delegate = self
        pushRegistry.desiredPushTypes = [.voIP]
    }
    
    // MARK: - PKPushRegistryDelegate Methods
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        let token : String = pushCredentials.token.map { String(format: "%02x", $0) }.joined()
        print("VoIP token: \(token)")
        // Send token to server or handle as needed
        UserDefaults.standard.set(token, forKey: "voip_token")
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        // Handle token invalidation
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        
        if(type != PKPushType.voIP){
            completion()
            return
        }
        
        // NSLog so the payload is visible in Console.app even when the push
        // launches the app without a debugger attached.
        NSLog("Received VoIP push notification: %@", payload.dictionaryPayload)
        
        let voipPayload = payload.dictionaryPayload
        
        let channelName =  voipPayload["channelName"]
        let conversationId = voipPayload["conversationId"]
        let messageId = voipPayload["messageId"]
        let conversationType = voipPayload["conversationType"]
        let callType = voipPayload["callType"]
        let callerId = voipPayload["caller_id"]
        let callerModelType = voipPayload["caller_model_type"]
        let callerName = voipPayload["caller_name"]
        let callerImage = voipPayload["caller_image"]
        let callPlacedAt = ((voipPayload["call_placed_at"] ?? 0) as? Double) ?? 0
        let tempCallId = voipPayload["temp_call_id"] ?? UUID().uuidString
        let incomingDeclined : Bool = CallPayload.boolFlag(voipPayload["incomming_declined"])
        
        
        let data : [String: Any] = [
            "channelName":channelName ?? "",
            "conversationId":conversationId ?? 0,
            "messageId":messageId ?? 0,
            "conversationType":conversationType ?? "oto",
            "callType":callType ?? "",
            "caller_id":callerId ?? 0,
            "caller_model_type":callerModelType ?? "",
            "caller_name":callerName ?? "",
            "caller_image" : callerImage ?? "",
            "call_placed_at" : callPlacedAt,
            "incomming_declined" : incomingDeclined,
            "temp_call_id":tempCallId
        ];
        
        let callUuid = UUID(uuidString: (tempCallId as? String) ?? "") ?? UUID()
        if let callPayload = CallPayload.fromDictionary(dictionary: NSDictionary(dictionary: data)) {
            
            let call = Call(uuid: callUuid, callPayload: callPayload, isOutGoing: false)
            
            if(incomingDeclined){
                // Cancelled / answered-elsewhere before answer: stop ringing.
                CallManager.shared.declineIncomingCall(callUuid: callUuid, conversationId: callPayload.conversationId)
                showMisscallNotification(title: "Missed Call", body: "You have a missed call from \(callPayload.callerName ?? "").")
                reportPushWithoutCallUI(callerName: callPayload.callerName ?? "")
            }
            else if(Date.differenceInSecondsFromMilliseconds(callPlacedAt) >= 35){
                showMisscallNotification(title: "Missed Call", body: "You have a missed call from \(callPayload.callerName ?? "").")
                reportPushWithoutCallUI(callerName: callPayload.callerName ?? "")
            }
            else if(!CallManager.shared.reportIncomingCall(call: call)){
                // receiver was busy, no call was posted for this push
                reportPushWithoutCallUI(callerName: callPayload.callerName ?? "")
            }
        }

        completion()
    }


    // iOS 13+ terminates apps that receive a VoIP push without reporting an
    // incoming call to CallKit, and repeat offenders stop getting VoIP pushes
    // at all. For pushes that must not ring (cancel / stale / busy), report a
    // placeholder call and end it immediately; .answeredElsewhere keeps it
    // out of the phone's recents and shows no missed-call entry.
    private func reportPushWithoutCallUI(callerName : String) {
        guard let provider = CallManager.shared.provider else { return }

        let uuid = UUID()
        let callUpdate = CXCallUpdate()
        callUpdate.remoteHandle = CXHandle(type: .generic, value: callerName)
        callUpdate.localizedCallerName = callerName

        provider.reportNewIncomingCall(with: uuid, update: callUpdate) { _ in
            provider.reportCall(with: uuid, endedAt: Date(), reason: .answeredElsewhere)
        }
    }
    
    
    func getVoipToken() -> String{
        return  UserDefaults.standard.string(forKey: "voip_token") ?? ""
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
            } else if let _ = error {
                
            }
        }
    }
    
}
