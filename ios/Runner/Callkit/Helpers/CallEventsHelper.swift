//
//  CallEventsHelper\.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//

import Foundation

class CallEventHelper{
    
    
    
    static func callRinging(payload : CallPayload){

        do{
            let myDetails = MyDetails.loadFromSharedPrefs()
            if(myDetails == nil){
                return
            }
            
            //Create url
            guard let url = URL(string: myDetails!.serverUrl! + "chat/agora/call") else {return}
            
            //Create request
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue( "Bearer \(myDetails!.token!)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            
            // making data for api call
            let jsonData : [String : Any] = [
                "eventName" : "call-ringing",
                "eventDetails" : [
                    "channelName" : payload.channelName as Any,
                    "conversationId" : payload.conversationId as Any,
                    "messageId" : payload.messageId as Any,
                    "conversationType" : payload.conversationType as Any,
                    "callType" : payload.callType as Any,
                ]
            ]
            
            // Convert the dictionary to JSON data
            let requestData = try JSONSerialization.data(withJSONObject: jsonData)
            
            // setting data in request
            request.httpBody = requestData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
            }
            task.resume()
        }
        catch(_){
        }
    }

    
    
    static func callRejected(payload : CallPayload){

        do{
            let myDetails = MyDetails.loadFromSharedPrefs()
            if(myDetails == nil){
                return
            }
            
            //Create url
            guard let url = URL(string: myDetails!.serverUrl! + "chat/agora/call") else {return}
            
            //Create request
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue( "Bearer \(myDetails!.token!)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            
            // making data for api call
            let jsonData : [String : Any] = [
                "eventName" : "call-declined",
                "eventDetails" : [
                    "channelName" : payload.channelName as Any,
                    "conversationId" : payload.conversationId as Any,
                    "messageId" : payload.messageId as Any,
                    "conversationType" : payload.conversationType as Any,
                    "callType" : payload.callType as Any,
                ]
            ]
            
            // Convert the dictionary to JSON data
            let requestData = try JSONSerialization.data(withJSONObject: jsonData)
            
            // setting data in request
            request.httpBody = requestData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
            }
            task.resume()
        }
        catch(_){
        }
    }
    
    
    
    static func callTimeOut(payload : CallPayload){

        do{
            let myDetails = MyDetails.loadFromSharedPrefs()
            if(myDetails == nil){
                return
            }
            
            //Create url
            guard let url = URL(string: myDetails!.serverUrl! + "chat/agora/call") else {return}
            
            //Create request
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue( "Bearer \(myDetails!.token!)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            
            // making data for api call
            let jsonData : [String : Any] = [
                "eventName" : "no-answer",
                "eventDetails" : [
                    "channelName" : payload.channelName as Any,
                    "conversationId" : payload.conversationId as Any,
                    "messageId" : payload.messageId as Any,
                    "conversationType" : payload.conversationType as Any,
                    "callType" : payload.callType as Any,
                ]
            ]
            
            // Convert the dictionary to JSON data
            let requestData = try JSONSerialization.data(withJSONObject: jsonData)
            
            // setting data in request
            request.httpBody = requestData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
            }
            task.resume()
        }
        catch(_){
        }
    }
    
    
    
    static func userBusy(payload : CallPayload){

        do{
            let myDetails = MyDetails.loadFromSharedPrefs()
            if(myDetails == nil){
                return
            }
            
            //Create url
            guard let url = URL(string: myDetails!.serverUrl! + "chat/agora/call") else {return}
            
            //Create request
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue( "Bearer \(myDetails!.token!)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            
            // making data for api call
            let jsonData : [String : Any] = [
                "eventName" : "user-bueasy",
                "eventDetails" : [
                    "channelName" : payload.channelName as Any,
                    "conversationId" : payload.conversationId as Any,
                    "messageId" : payload.messageId as Any,
                    "conversationType" : payload.conversationType as Any,
                    "callType" : payload.callType as Any,
                ]
            ]
            
            // Convert the dictionary to JSON data
            let requestData = try JSONSerialization.data(withJSONObject: jsonData)
            
            // setting data in request
            request.httpBody = requestData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
            }
            task.resume()
        }
        catch(_){
        }
    }

    
    
    static func ongoingCallDeclined(payload : CallPayload){

        do{
            let myDetails = MyDetails.loadFromSharedPrefs()
            if(myDetails == nil){
                return
            }
            
            //Create url
            guard let url = URL(string: myDetails!.serverUrl! + "chat/agora/call") else {return}
            
            //Create request
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue( "Bearer \(myDetails!.token!)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            
            //
            // preparing notification payload
            var notificationPayload = payload.toDictionary()
            notificationPayload["incomming_declined"] = true as Any
            notificationPayload["call_placed_at"] = Int(Date().timeIntervalSince1970 * 1000) as Any
            
            
            // making data for api call
            let jsonData : [String : Any] = [
                "eventName" : "incomming-call-declined",
                "eventDetails" : notificationPayload
            ]
            
            print("json to request for incomming declined call\(jsonData)")
                        
            // Convert the dictionary to JSON data
            let requestData = try JSONSerialization.data(withJSONObject: jsonData)
            
            print("data to request for incomming declined call\(requestData)")
            
            // setting data in request
            request.httpBody = requestData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data else{
                    print("data is null")
                    return
                }
                
                if let responseString = String(data: data, encoding: .utf8) {
                    print("responseString of reponse\(responseString)")
                }
                else{
                    print("responseString is returning null")
                }
            }
            task.resume()
        }
        catch(_){
        }
    }
    
    
    
    static func callAccepted(payload : CallPayload){

            do{
                let myDetails = MyDetails.loadFromSharedPrefs()
                if(myDetails == nil){
                    return
                }
                
                //Create url
                guard let url = URL(string: myDetails!.serverUrl! + "chat/agora/call") else {return}
                
                //Create request
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue( "Bearer \(myDetails!.token!)", forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                
                
                // making data for api call
                let jsonData : [String : Any] = [
                    "eventName" : "call-accepted",
                    "eventDetails" : [
                        "channelName" : payload.channelName as Any,
                        "conversationId" : payload.conversationId as Any,
                        "messageId" : payload.messageId as Any,
                        "conversationType" : payload.conversationType as Any,
                        "callType" : payload.callType as Any,
                    ]
                ]
                
                // Convert the dictionary to JSON data
                let requestData = try JSONSerialization.data(withJSONObject: jsonData)
                
                // setting data in request
                request.httpBody = requestData
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                }
                task.resume()
            }
            catch(_){
            }
        }


}
