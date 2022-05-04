//
//  ChatMessage.swift
//  CommunicationFramework
//
//  Created by Conrad Felgentreff on 29.04.22.
//

import Foundation

struct ChatMessage: Identifiable, Hashable {
    
    private(set) var id: UUID
    private(set) var senderIdentifier: String
    private(set) var sender: String
    private(set) var message: String
    private(set) var createdOn: Date
    
    init(senderIdentifier: String, sender: String, message: String, createdOn: Date) {
        self.id = UUID()
        self.senderIdentifier = senderIdentifier
        self.sender = sender
        self.message = message
        self.createdOn = createdOn
    }
}
