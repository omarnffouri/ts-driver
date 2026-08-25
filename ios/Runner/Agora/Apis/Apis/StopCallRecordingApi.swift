//
//  StopCallRecordingApi.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//


import Foundation


class StopCallRecordingApi : ObservableObject{
    
    @Published var isLoading : Bool = false
    
    
    func stopCallRecording(channelName : String, messageId : Int, callRecordingDetails : StartCallRecordingModel) async {
        
        
        guard !isLoading else { return }
                
        guard let myDetails = MyDetails.loadFromSharedPrefs() else {
            return
        }
        
        
        // The URL for the POST request
        guard let url = URL(string: myDetails.serverUrl! + "chat/agora/stopCallRecording") else {
            return
        }
        
        
        // Data to be sent as a key-value map (dictionary)
        let jsonData: [String: Any] = [
            "messageId":  messageId,
            "channelName": channelName,
            "uid": callRecordingDetails.uid as Any,
            "resourceId": callRecordingDetails.resourceId as Any,
            "sid": callRecordingDetails.sid as Any
        ]
        
        // Convert the dictionary into JSON data
        guard let requestData = try? JSONSerialization.data(withJSONObject: jsonData) else {
            return
        }
        
        
        // Create the URLRequest with POST method and set the body
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue( "Bearer \(myDetails.token!)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestData
        
        
        isLoading = true
        
        do {
            // Make the network request using async/await
            let (data, response) = try await URLSession.shared.data(for: request)
            
            isLoading = false
            
            
            let responseJson = try? JSONSerialization.jsonObject(with: data, options: [])
            print("stopCallRecording response: \(responseJson as Any)")
            
            // Check if the response is successful (status code 200)
//            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
//                
//                
//            } else {
//                return
//            }
        } catch {
            return
        }
    }
    
}
