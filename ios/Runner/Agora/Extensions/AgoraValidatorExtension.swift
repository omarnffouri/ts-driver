//
//  AgoraValidatorExtension.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//

extension AgoraManager {
    
    
    //
    // function to validate the call params before loading the required data
    // this will ensure the call details that needs in order to receive or make the call
    func validateCallParams(call : CallPayload) -> Bool{
        //
        // check  conversation id
        if call.conversationId == nil {
            print("conversation id is nil while accepting the call")
            return false
        }
        
        //
        // check  channelName
        if call.channelName  == nil {
            print("channel name is nil while accepting the call")
            
            return false
        }
        
        //
        // check  conversation type
        if call.conversationType != "oto" && call.conversationType != "group" {
            print("conversation type is nil or in valid while accepting the call ===> \(String(describing: call.conversationType))")
            return false
        }
        
        return true;
    }
}
