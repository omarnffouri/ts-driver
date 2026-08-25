//
//  CallUser.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//


class CallUser: ObservableObject , Equatable , Hashable {
    
    
    @Published var participant: ParticipantModel?
    @Published var remoteId: Int
    @Published var videoMuted: Bool = false
    @Published var micMuted: Bool = false
    @Published var isSpeaking: Bool = false
    
    init(remoteId: Int, participant: ParticipantModel? = nil) {
        self.remoteId = remoteId
        self.participant = participant
    }
    
    static func == (lhs: CallUser, rhs: CallUser) -> Bool {
        return lhs.remoteId == rhs.remoteId && lhs.participant == rhs.participant
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(remoteId)
        hasher.combine(participant)
    }
}
