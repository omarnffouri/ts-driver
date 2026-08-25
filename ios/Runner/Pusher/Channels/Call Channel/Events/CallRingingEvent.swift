//
//  CallRingingEvent.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//


extension CallChannel {
    
    
    func bindCallRingingEvent(_ callback: @escaping (CallEventDataModel) -> Void) -> String? {
        
        guard let channel = getCallChannel() else {
            return nil
        }
        
        return channel.bind(eventName: CallChannelEvents.callRinging.getName(), eventCallback: { event in
            do{
                guard let json: String = event.data,
                      let jsonData: Data = json.data(using: .utf8) else{
                    return
                }
                self.printLog("got a call ringing event ===> \(json)")
                guard let parsedData = try JSONDecoder().decode(CallEventDataModel?.self, from: jsonData) else { return }
                self.printLog("call ringing event parsed successfully")
                callback(parsedData)
            }
            catch{
            }
            
        })
    }
    
    
    func unbindCallRingingEvent(_ eventId: String?) {
        guard let id = eventId else { return }
        guard let channel = getCallChannel() else { return }
        channel.unbind(eventName: CallChannelEvents.callRinging.getName(), callbackId: id)
    }
    
}
