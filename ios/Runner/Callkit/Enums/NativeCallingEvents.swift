//
//  NativeCallingEvents.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//

public enum NativeCallingEvents {
    case callReceived
    case callPlaced
    case callTime
    case callEnded
    case callDeclined
    case callNoAnswer
    case callUserBusy
    case callFailed
    
    func getName() -> String {
        switch self {
        case .callReceived:
            return "callReceived"
        case .callTime:
            return "callTime"
        case .callEnded:
            return "callEnded"
        case .callPlaced:
            return "callPlaced"
        case .callDeclined:
            return "callDeclined"
        case .callNoAnswer:
            return "callNoAnswer"
        case .callUserBusy:
            return "callUserBusy"
        case .callFailed:
            return "callFailed"
        }
    }
}
