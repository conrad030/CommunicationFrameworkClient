//
//  MockChatModel.swift
//  CommunicationFrameworkTests
//
//  Created by Conrad Felgentreff on 10.06.22.
//

import Foundation
@testable import CommunicationFramework

class MockChatModel: ObservableObject, ChatModel {
    
    var delegate: ChatModelDelegate?
    var threadId: String? {
        didSet {
            self.delegate?.modelSetupFinished()
        }
    }
    
    var completedMessageFetch: Bool = false
    
    @Published private(set) var initChatModelCalled = false
    @Published private(set) var startRealTimeNotificationsCalled = false
    @Published private(set) var startChatCalled = false
    @Published private(set) var getThreadMessagesCalled = false
    @Published private(set) var sendReadReceiptCalled = false
    @Published private(set) var sendMessageCalled = false
    @Published private(set) var deleteMessageCalled = false
    @Published private(set) var invalidateCalled = false
    
    func initChatModel(endpoint: String, identifier: String, token: String, displayName: String) throws {
        self.initChatModelCalled = true
    }
    
    func startRealTimeNotifications() {
        self.startRealTimeNotificationsCalled = true
    }
    
    func startChat(partnerIdentifier identifier: String, partnerDisplayName displayName: String) {
        self.threadId = UUID().uuidString
    }
    
    func getThreadMessages() {
        self.getThreadMessagesCalled = true
        self.delegate?.handleGetThreadMessages(items: [])
        self.completedMessageFetch = true
        self.delegate?.sendReadReceipts()
    }
    
    func sendReadReceipt(for messageId: String) {
        self.sendReadReceiptCalled = true
    }
    
    func sendMessage(message: ChatMessage, completion: @escaping (String) -> Void) {
        self.sendMessageCalled = true
        completion(UUID().uuidString)
    }
    
    func deleteMessage(messageId: String, completion: @escaping (Bool) -> Void) {
        self.deleteMessageCalled = true
        completion(true)
    }
    
    func invalidate() {
        self.invalidateCalled = true
    }
}
