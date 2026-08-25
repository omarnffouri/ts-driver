//
//  CallAcceptedEvent.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//


extension CallChannel {
    
    
    func bindCallAcceptedEvent(_ callback: @escaping (CallEventDataModel) -> Void) -> String? {
        
        guard let channel = getCallChannel() else {
            return nil
        }
        
        return channel.bind(eventName: CallChannelEvents.callAccepted.getName(), eventCallback: { event in
            do{
                guard let json: String = event.data,
                      let jsonData: Data = json.data(using: .utf8) else{
                    return
                }
                self.printLog("got a call accepted event ===> \(json)")
                guard let parsedData = try JSONDecoder().decode(CallEventDataModel?.self, from: jsonData) else { return }
                self.printLog("call accepted event parsed successfully")
                callback(parsedData)
            }
            catch{
            }
            
        })
    }
    
    
    func unbindCallAcceptedEvent(_ eventId: String?) {
        guard let id = eventId else { return }
        guard let channel = getCallChannel() else { return }
        channel.unbind(eventName: CallChannelEvents.callAccepted.getName(), callbackId: id)
    }
    
}
