//
//  AgoraCallDataLoaderExtension.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//

extension AgoraManager {
    
    
    
    //
    // function to load a data before startin the call
    // returns true if data loaded successfuly, else false
    func loadCallData() -> Bool {
        
        guard let myDetails = MyDetails.loadFromSharedPrefs() else {
            print("My details not found on load call data function")
            return false
        }
        
        self.myDetails = myDetails
        
        print("My details loaded successfully on load call data function \(String(describing: myDetails.applicantId))")
        
        guard  let callPayload = currentCall?.callPayload , validateCallParams(call : callPayload) else {
            print("Call params validation failed on load call data function")
            return false
        }
        
        //
        // check if conversation type is group then load conversation details from group conversations db and table
        // else load from oto conversations db and table
        if(callPayload.conversationType == "group"){
            return loadGroupCallData(callPayload : callPayload, myDetails: myDetails)
        }
        else{
            return loadOtoCallData(callPayload : callPayload, myDetails: myDetails)
        }
    }
    
    //
    // function to load a call data/details for the group call
    private func loadGroupCallData(callPayload : CallPayload,  myDetails : MyDetails) -> Bool {
        do{
            
            guard let conversation = try DatabaseManager.shared.fetchGroupConversation(conversationId:  callPayload.conversationId!) else{
               print("Group conversation not found on load oto call data function")
                return false;
            }
            
            guard let participants = conversation.participants else{
                print("Group participants not found on load oto call data function")
                return false
            }
            
            return loadParticipantsAndPid(participants: participants, myDetails: myDetails)
        }
        catch {
            return false;
        }
    }
    
    //
    // function to load a call data/details for the oto call
    private func loadOtoCallData(callPayload : CallPayload, myDetails : MyDetails) -> Bool {
        do{
            
            guard let conversation = try DatabaseManager.shared.fetchOtoConversation(conversationId:  callPayload.conversationId!) else{
               print("Oto conversation not found on load oto call data function")
                return false;
            }
            
            guard let participants = conversation.participants else{
                print("Oto participants not found on load oto call data function")
                return false
            }
            
            return loadParticipantsAndPid(participants: participants, myDetails: myDetails)
        }
        catch {
            return false;
        }
    }

    //
    // function to load participants and myPid
    private func loadParticipantsAndPid(participants : [ParticipantModel], myDetails : MyDetails) -> Bool {
        
        
        guard let myPid = participants.first(where: {
            ($0.id != nil) &&
            ($0.id == myDetails.applicantId) &&
            $0.modelType == "applicants"
        })?.pid else{
            print("myPid not found on load participants and pid function ===> \(participants) , \(myDetails)")
            print("myPid not found on load participants and pid function ===>  \(myDetails)")
            return false
        }
        
        print("my pid loaded ===> \(myPid)")
        
        self.participants.removeAll()
        self.participants.append(contentsOf: participants)
        self.myPid = myPid
        
        return true
    }
    
    
    func getOpositeUserImage() -> String?{
        guard let call = currentCall else{
            return nil
        }
        
        if call.callPayload.conversationType == "group" {
            return groupSettings?.logo
        }
        else{
            let par = participants.first(where: {$0.pid != myPid})
            return par?.image
        }
    }
}
