//
//  ChatViewModelTests.swift
//  CommunicationFrameworkTests
//
//  Created by Conrad Felgentreff on 10.06.22.
//

import XCTest
import CoreData
@testable import CommunicationFramework

class ChatViewModelTests: XCTestCase {
    
    var sut: ChatViewModel!
    lazy var testContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ChatStore")
        container.persistentStoreDescriptions[0].url = URL(fileURLWithPath: "/dev/null")
        container.loadPersistentStores { description, error in
            XCTAssertNil(error)
        }
        return container
    }()
    var context: NSManagedObjectContext {
        self.testContainer.newBackgroundContext()
    }
    var senderIdentifier = UUID().uuidString
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        self.sut = ChatViewModel(chatModel: MockChatModel(), container: self.testContainer)
    }
    
    override func tearDownWithError() throws {
        self.sut = nil
        try super.tearDownWithError()
    }
    
    private func getNewChatMessage(withPdfFile: Bool = false) -> ChatMessage {
        let message = ChatMessage(context: self.context)
        message.id = UUID()
        message.senderIdentifier = self.senderIdentifier
        message.message = "test"
        message.status = .sent
        if withPdfFile {
            message.file = self.getNewPdf()
        }
        return message
    }
    
    private func getNewPdf() -> File {
        let file = File(context: self.context)
        file.id = UUID()
        file.name = "testFile"
        file.type = .pdf
        let bundle = Bundle(for: ChatViewModelTests.self)
        file.data = NSDataAsset(name: "TestPdfData", bundle: bundle)!.data
        return file
    }
    
    func testSetup() {
        XCTAssertEqual(self.sut.chatMessages.count, 0, "Chat messages from Viewmodel are not empty")
        XCTAssertEqual(self.sut.chatIsSetup, false, "Chat is setup before being initialized")
        XCTAssertEqual(self.sut.chatPartnerName, nil, "Chatpartnername should be nil before Viewmodel is initialized")
        XCTAssertEqual(self.sut.loadedMessages, false, "loadedMessages is true before Viewmodel is initialized")
    }
    
    /// Can only be tested in local database
    func testSendMessage() {
        let text = "test"
        self.sut.sendMessage(text: text, fileRepresentable: nil)
        XCTAssertEqual(self.sut.chatMessages.count, 1, "Sent chat message is not included in Viewmodels chat messages")
        XCTAssertEqual(self.sut.chatMessages.last!.message, text, "Text of chat message in Viewmodel is wrong")
        XCTAssertNil(self.sut.chatMessages.last!.file, "File is not nil")
    }
    
    func testSendMessageWithImage() {
        let bundle = Bundle(for: ChatViewModelTests.self)
        let image = UIImage(named: "TestImage", in: bundle, with: .none)!
        let text = "imageTest"
        self.sut.sendMessage(text: text, fileRepresentable: image)
        XCTAssertEqual(self.sut.chatMessages.count, 1, "Sent chat message is not included in Viewmodels chat messages")
        XCTAssertEqual(self.sut.chatMessages.last!.message, text, "Text of chat message in Viewmodel is wrong")
        XCTAssertNotNil(self.sut.chatMessages.last!.file, "File is nil")
        XCTAssertEqual(self.sut.chatMessages.last!.file!.name, image.name, "Text of chat message in Viewmodel is wrong")
        XCTAssertEqual(self.sut.chatMessages.last!.file!.type, image.fileType, "Text of chat message in Viewmodel is wrong")
        XCTAssertEqual(self.sut.chatMessages.last!.file!.data, image.data, "Text of chat message in Viewmodel is wrong")
    }
    
    func testSendMessageWithPdf() {
        let bundle = Bundle(for: ChatViewModelTests.self)
        let pdfFile = PDFFile(data: NSDataAsset(name: "TestPdfData", bundle: bundle)!.data)
        let text = "pdfTest"
        self.sut.sendMessage(text: text, fileRepresentable: pdfFile)
        XCTAssertEqual(self.sut.chatMessages.count, 1, "Sent chat message is not included in Viewmodels chat messages")
        XCTAssertEqual(self.sut.chatMessages.last!.message, text, "Text of chat message in Viewmodel is wrong")
        XCTAssertNotNil(self.sut.chatMessages.last!.file, "File is nil")
        XCTAssertEqual(self.sut.chatMessages.last!.file!.name, pdfFile.name, "Text of chat message in Viewmodel is wrong")
        XCTAssertEqual(self.sut.chatMessages.last!.file!.type, pdfFile.fileType, "Text of chat message in Viewmodel is wrong")
        XCTAssertEqual(self.sut.chatMessages.last!.file!.data, pdfFile.data, "Text of chat message in Viewmodel is wrong")
    }
    
    func testDeleteMessageLocally() {
        let text = "test"
        self.sut.sendMessage(text: text, fileRepresentable: nil)
        self.sut.deleteMessageLocally(message: self.sut.chatMessages.first!)
        XCTAssertEqual(self.sut.chatMessages.count, 0, "Messages of Viewmodel should be empty")
    }
    
    func testDeleteReadMessageRemote() {
        let message = self.getNewChatMessage()
        self.sut.deleteMessageForAll(message: message) { success in
            XCTAssertTrue(success, "Message couldn't be deleted")
        }
    }
    
    func testDeleteReadMessage() {
        let message = self.getNewChatMessage()
        message.status = .read
        self.sut.deleteMessageForAll(message: message) { success in
            XCTAssertFalse(success, "Message was deleted for everyone, although it's status is read")
        }
    }
}
