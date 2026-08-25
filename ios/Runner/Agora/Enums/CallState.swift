//
//  CallState.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//

enum CallState {
    case idle
    case calling
    case ringing
    case declined
    case userBusy
    case connecting
    case connected
    case failed
    case notAnswered
    
    
    // Method to get the name of the enum case as a string
    func getName() -> String {
        switch self {
        case .idle:
            return "Calling..."
        case .calling:
            return "Calling..."
        case .ringing:
            return "Ringing..."
        case .declined:
            return "Declined"
        case .userBusy:
            return "User Busy"
        case .connecting:
            return "Connecting..."
        case .connected:
            return "Connected"
        case .failed:
            return "Failed"
        case .notAnswered:
            return "Not Answered"
        }
    }
}
