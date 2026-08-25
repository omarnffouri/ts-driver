//
//  CallUserBusyEvent.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//


extension CallChannel {
    
    
    func bindCallUserBusyEvent(_ callback: @escaping (CallEventDataModel) -> Void) -> String? {
        
        guard let channel = getCallChannel() else {
            return nil
        }
        
        return channel.bind(eventName: CallChannelEvents.userBueasy.getName(), eventCallback: { event in
            do{
                guard let json: String = event.data,
                      let jsonData: Data = json.data(using: .utf8) else{
                    return
                }
                self.printLog("got a call user busy event ===> \(json)")
                guard let parsedData = try JSONDecoder().decode(CallEventDataModel?.self, from: jsonData) else { return }
                self.printLog("call user busy event parsed successfully")
                callback(parsedData)
            }
            catch{
            }
            
        })
    }
    
    
    func unbindCallUserBusyEvent(_ eventId: String?) {
        guard let id = eventId else { return }
        guard let channel = getCallChannel() else { return }
        channel.unbind(eventName: CallChannelEvents.userBueasy.getName(), callbackId: id)
    }
    
}
