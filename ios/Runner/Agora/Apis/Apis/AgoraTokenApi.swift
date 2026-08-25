//
//  AgoraTokenApi.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//


import Foundation


class AgoraTokenApi{
    
    
    
    // Async function to send data as key-value pairs in URL-encoded format
    static func getAgoraToken(channelName : String, joiningAs : JoiningAs, pid : Int) async -> String? {
        
        
        guard let myDetails = MyDetails.loadFromSharedPrefs() else {
            return nil
        }
        
        
        // The URL for the POST request
        guard let url = URL(string: myDetails.serverUrl! + "chat/agora/token") else {
            return nil
        }
        
        
        // Data to be sent as a key-value map (dictionary)
        let jsonData: [String: Any] = [
            "role":  joiningAs.getName(),
            "channelName": channelName,
            "user": pid
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
        
        
        
        do {
            // Make the network request using async/await
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Check if the response is successful (status code 200)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                // Handle the response data (e.g., decode it into a model if needed)
                if let responseString = String(data: data, encoding: .utf8) {
                    return responseString.trimmingCharacters(in: .whitespacesAndNewlines)
                        .replacingOccurrences(of: "\"", with: "")
                }
                else{
                    return nil
                }
            } else {
                return nil
            }
        } catch {
            // Handle errors (e.g., network issues, timeout, etc.)
            return nil
        }
    }
    
}
