//
//  CallPayload.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//



public class CallPayload {
    
    var conversationType: String?
    var callerName: String?
    var conversationId: Int?
    var messageId: Int?
    var callerId: Int?
    var callerModelType: String?
    var channelName: String?
    var callType: String?
    var callerImage: String?
    var incomingDeclined: Bool?
    var tempCallId: String
    var receiverName : String?
    var receiverImage : String?


    init(conversationType: String?,
         callerName: String?,
         conversationId: Int?,
         messageId: Int?,
         callerId: Int?,
         callerModelType: String?,
         channelName: String?,
         callType: String?,
         callerImage: String?,
         incomingDeclined: Bool?,
         tempCallId: String) {
        self.conversationType = conversationType
        self.callerName = callerName
        self.conversationId = conversationId
        self.messageId = messageId
        self.callerId = callerId
        self.callerModelType = callerModelType
        self.channelName = channelName
        self.callType = callType
        self.callerImage = callerImage
        self.incomingDeclined = incomingDeclined
        self.tempCallId = tempCallId
    }

    // Server payloads carry boolean flags inconsistently: JSON bools in VoIP
    // pushes, "1"/"true" strings in FCM data messages. Accept all of them.
    static func boolFlag(_ value: Any?) -> Bool {
        if let boolValue = value as? Bool {
            return boolValue
        }
        if let numberValue = value as? NSNumber {
            return numberValue.boolValue
        }
        if let stringValue = value as? String {
            let normalized = stringValue.lowercased()
            return normalized == "1" || normalized == "true"
        }
        return false
    }

    // Convert the class object to a dictionary
    func toDictionary() -> [String: Any] {
        return [
            "conversationType": conversationType ?? "",
            "caller_name": callerName ?? "",
            "conversationId": conversationId ?? 0,
            "messageId": messageId ?? 0,
            "caller_id": callerId ?? 0,
            "caller_model_type": callerModelType ?? "",
            "channelName": channelName ?? "",
            "callType": callType ?? "",
            "caller_image": callerImage ?? "",
            "incomming_declined": incomingDeclined ?? false,
            "temp_call_id": tempCallId,
            "receiverName": receiverName ?? "",
            "receiverImage": receiverImage ?? "",
        ]
    }

    // Initialize the class object from a dictionary
    static func fromDictionary(dictionary: NSDictionary) -> CallPayload? {
            
            let callPayload =  CallPayload(
                conversationType: dictionary["conversationType"] as? String,
                callerName: dictionary["caller_name"] as? String,
                conversationId: dictionary["conversationId"] as? Int ?? 0,
                messageId: dictionary["messageId"]  as? Int ?? 0,
                callerId: dictionary["caller_id"] as? Int ?? 0,
                callerModelType: dictionary["caller_model_type"] as? String,
                channelName: dictionary["channelName"] as? String,
                callType: dictionary["callType"] as? String,
                callerImage: dictionary["caller_image"] as? String,
                incomingDeclined: boolFlag(dictionary["incomming_declined"]),
                tempCallId: dictionary["temp_call_id"] as? String ?? UUID().uuidString
            )

            callPayload.receiverName = dictionary["receiverName"] as? String
            callPayload.receiverImage = dictionary["receiverImage"] as? String

            return callPayload
        }

        static func fromDictionaryFcm(dictionary: NSDictionary) -> CallPayload? {
            
            //        print("data before conversion: \(dictionary)")
            
            let callPayload =  CallPayload(
                conversationType: dictionary["conversationType"] as? String,
                callerName: dictionary["caller_name"] as? String,
                conversationId:  Int(dictionary["conversationId"] as? String ?? "0"),
                messageId: Int(dictionary["messageId"]  as? String ?? "0"),
                callerId: Int(dictionary["caller_id"] as? String ?? "0"),
                callerModelType: dictionary["caller_model_type"] as? String,
                channelName: dictionary["channelName"] as? String,
                callType: dictionary["callType"] as? String,
                callerImage: dictionary["caller_image"] as? String,
                incomingDeclined: boolFlag(dictionary["incomming_declined"]),
                tempCallId: dictionary["temp_call_id"] as? String ?? UUID().uuidString
            )

            callPayload.receiverName = dictionary["receiverName"] as? String
            callPayload.receiverImage = dictionary["receiverImage"] as? String

            return callPayload
        }
    }
