//
//  ChatMessage.swift
//  CommunicationFramework
//
//  Created by Conrad Felgentreff on 29.04.22.
//

import Foundation

struct ChatMessage: Identifiable, Hashable {
    
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine("\(self.id)\(self.senderIdentifier)\(self.message ?? "")\(self.createdOn)\(self.fileHolder?.file?.data ?? Data())")
    }
    
    private(set) var id: UUID
    private(set) var senderIdentifier: String
    private(set) var sender: String
    private(set) var message: String?
    private(set) var createdOn: Date
    var fileHolder: FileHolder?
    
    init(id: String? = nil, senderIdentifier: String, sender: String, message: String?, createdOn: Date, fileWrapper: FileHolder? = nil) {
        self.id = UUID(uuidString: id ?? UUID().uuidString) ?? UUID()
        self.senderIdentifier = senderIdentifier
        self.sender = sender
        self.message = message
        self.createdOn = createdOn
        self.fileHolder = fileWrapper
    }
}
