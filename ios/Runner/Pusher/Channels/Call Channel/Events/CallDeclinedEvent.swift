//
//  CallDeclinedEvent.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//


extension CallChannel {
    
    
    func bindCallDeclinedEvent(_ callback: @escaping (CallEventDataModel) -> Void) -> String? {
        
        guard let channel = getCallChannel() else {
            return nil
        }
        
        return channel.bind(eventName: CallChannelEvents.callDeclined.getName(), eventCallback: { event in
            do{
                guard let json: String = event.data,
                      let jsonData: Data = json.data(using: .utf8) else{
                    return
                }
                self.printLog("got a call declined event ===> \(json)")
                guard let parsedData = try JSONDecoder().decode(CallEventDataModel?.self, from: jsonData) else { return }
                self.printLog("call declined event parsed successfully")
                callback(parsedData)
            }
            catch{
            }
            
        })
    }
    
    
    func unbindCallDeclinedEvent(_ eventId: String?) {
        guard let id = eventId else { return }
        guard let channel = getCallChannel() else { return }
        channel.unbind(eventName: CallChannelEvents.callDeclined.getName(), callbackId: id)
    }


    // caller cancelled the call (or it was handled elsewhere) while we are ringing
    func bindIncommingCallDeclinedEvent(_ callback: @escaping (CallEventDataModel) -> Void) -> String? {

        guard let channel = getCallChannel() else {
            return nil
        }

        return channel.bind(eventName: CallChannelEvents.incommingCallDeclined.getName(), eventCallback: { event in
            do{
                guard let json: String = event.data,
                      let jsonData: Data = json.data(using: .utf8) else{
                    return
                }
                self.printLog("got a incomming call declined event ===> \(json)")
                guard let parsedData = try JSONDecoder().decode(CallEventDataModel?.self, from: jsonData) else { return }
                self.printLog("incomming call declined event parsed successfully")
                callback(parsedData)
            }
            catch{
            }

        })
    }


    func unbindIncommingCallDeclinedEvent(_ eventId: String?) {
        guard let id = eventId else { return }
        guard let channel = getCallChannel() else { return }
        channel.unbind(eventName: CallChannelEvents.incommingCallDeclined.getName(), callbackId: id)
    }

}
