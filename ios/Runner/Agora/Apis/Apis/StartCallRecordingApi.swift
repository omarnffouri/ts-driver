//
//  StartCallRecordingApi.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//


import Foundation


class StartCallRecordingApi : ObservableObject{
    
    @Published var isLoading : Bool = false
    
    
    func startCallRecording(channelName : String, messageId : Int) async -> StartCallRecordingModel?  {
        
        guard !isLoading else { return nil }
                
        guard let myDetails = MyDetails.loadFromSharedPrefs() else {
            return nil
        }
        
        
        // The URL for the POST request
        guard let url = URL(string: myDetails.serverUrl! + "chat/agora/startCallRecording") else {
            return nil
        }
        
        
        // Data to be sent as a key-value map (dictionary)
        let jsonData: [String: Any] = [
            "messageId":  messageId,
            "channelName": channelName,
            "uid": generateRandomSixDigitNumber()
        ]
        
        // Convert the dictionary into JSON data
        guard let requestData = try? JSONSerialization.data(withJSONObject: jsonData) else {
            return nil
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
            print("startCallRecording response: \(responseJson as Any)")
            
            // Check if the response is successful (status code 200)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                
                return try JSONDecoder().decode(StartCallRecordingModel.self, from: data)
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
    
    
    
    private func generateRandomSixDigitNumber() -> Int {
        return Int.random(in: 100000...999999)
    }
}
