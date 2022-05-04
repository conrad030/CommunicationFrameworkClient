//
//  ChatViewModel.swift
//  CommunicationFramework
//
//  Created by Conrad Felgentreff on 27.04.22.
//

import SwiftUI
import AzureCommunicationCommon
import AzureCommunicationChat

class ChatViewModel: NSObject, ObservableObject {
    
    /// The singleton instance of the Viewmodel
    public static let shared: ChatViewModel = ChatViewModel()
    
    private var chatClient: ChatClient?
    private var chatThreadClient: ChatThreadClient? {
        didSet {
            self.getThreadMessages { success in
                if !success {
                    // TODO: Display error
                }
                self.loadedMessages = false
            }
        }
    }
    
    @Published public var threadId: String? {
        didSet {
            if let threadId = self.threadId {
                do {
                    self.chatThreadClient = try self.chatClient?.createClient(forThread: threadId)
                } catch {
                    print("ChatThreadClient couldn't be initialized.")
                }
            }
        }
    }
    @Published public var messages: [ChatMessage] = []
    @Published public var chatPartnerName: String?
    @Published public var loadedMessages = true
    
    private var hasChatThreadClient: Bool {
        self.chatThreadClient != nil
    }
    
    override private init() {
        super.init()
    }
    
    public func initChatClient() {
        if !CommunicationFrameworkHelper.endpoint.isEmpty && !CommunicationFrameworkHelper.token.isEmpty {
            /// Create chat client
            do {
                let credentialOptions = CommunicationTokenRefreshOptions(initialToken: CommunicationFrameworkHelper.token, tokenRefresher: { result in
                    print("Refreshed token.")
                })
                let credential = try CommunicationTokenCredential(withOptions: credentialOptions)
                let options = AzureCommunicationChatClientOptions()
                self.chatClient = try ChatClient(endpoint: CommunicationFrameworkHelper.endpoint, credential: credential, withOptions: options)
            } catch {
                print("Error while creating chatClient: \(error.localizedDescription)")
            }
            
            /// Receive chat messages
            self.chatClient?.startRealTimeNotifications { result in
                switch result {
                case .success:
                    print("Real-time notifications started.")
                case .failure:
                    print("Failed to start real-time notifications.")
                }
            }
            
            self.chatClient?.register(event: .chatMessageReceived) { response in
                switch response {
                case let .chatMessageReceivedEvent(event):
                    print("Received a message: \(event.message)")
                    DispatchQueue.main.async {
                        let sender = event.sender as? CommunicationUserIdentifier
                        /// Only add message if sender is the chat partner
                        if let sender = sender, sender.identifier != CommunicationFrameworkHelper.id {
                            let chatMessage = ChatMessage(senderIdentifier: sender.identifier, sender: event.senderDisplayName ?? "", message: event.message, createdOn: event.createdOn?.value ?? Date())
                            withAnimation {
                                self.messages.append(chatMessage)
                            }
                        }
                    }
                default:
                    return
                }
            }
        } else {
            print("ChatClient couldn't be initialized. Credentials are missing.")
        }
    }
    
    public func startChat(with identifier: String, displayName: String) {
        self.chatPartnerName = displayName
        self.initThread(identifier: identifier, displayName: displayName)
    }
    
    private func initThread(identifier: String, displayName: String) {
        if CommunicationFrameworkHelper.id.isEmpty || CommunicationFrameworkHelper.displayName.isEmpty {
            print("Identifier and/or displayname are missing. Couldn't initialize chat thread.")
            return
        }
        
        self.getActiveThread { chatThreadItem in
            if let chatThreadItem = chatThreadItem {
                self.threadId = chatThreadItem.id
                self.addParticipant(identifier: identifier, displayName: displayName)
            } else {
                
                let request = CreateChatThreadRequest(
                    topic: "Quickstart",
                    participants: [
                        ChatParticipant(
                            id: CommunicationUserIdentifier(CommunicationFrameworkHelper.id),
                            displayName: CommunicationFrameworkHelper.displayName
                        )
                    ]
                )
                
                self.chatClient?.create(thread: request) { result, _ in
                    switch result {
                    case let .success(result):
                        self.threadId = result.chatThread?.id
                        self.addParticipant(identifier: identifier, displayName: displayName)
                    case .failure:
                        fatalError("Failed to create thread.")
                    }
                }
            }
        }
    }
    
    private func getActiveThread(completion: @escaping (ChatThreadItem?) -> Void) {
        self.chatClient?.listThreads { result, _ in
            switch result {
            case let .success(threads):
                guard let chatThreadItems = threads.pageItems else {
                    print("No threads returned.")
                    return
                }
                
                return completion(chatThreadItems.first)
            case .failure:
                print("Failed to list threads")
                return completion(nil)
            }
        }
    }
    
    private func getThreadMessages(completion: @escaping (Bool) -> Void) {
        let options = ListChatMessagesOptions(maxPageSize: 200)
        self.chatThreadClient?.listMessages(withOptions: options) { result, _ in
            switch result {
            case let .success(listMessagesResponse):
                print("Nachrichten: \(listMessagesResponse.items?.count ?? -1)")
                if let items = listMessagesResponse.items {
                    for item in items {
                        let sender = item.sender as? CommunicationUserIdentifier
                        let chatMessage = ChatMessage(senderIdentifier: sender?.identifier ?? "", sender: item.senderDisplayName ?? "Unbekannt", message: item.content?.message ?? "Kein Inhalt", createdOn: item.createdOn.value)
                        self.messages.append(chatMessage)
                    }
                }
                completion(true)
            case let .failure(error):
                print("Error while listing messages: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    public func sendMessage(text: String) {
        let message = SendChatMessageRequest(
            content: text,
            senderDisplayName: CommunicationFrameworkHelper.displayName,
            type: .text,
            metadata: nil
        )
        
        if self.hasChatThreadClient {
            withAnimation {
                self.messages.append(ChatMessage(senderIdentifier: CommunicationFrameworkHelper.id, sender: CommunicationFrameworkHelper.displayName, message: message.content, createdOn: Date()))
            }
            self.chatThreadClient!.send(message: message) { result, _ in
                switch result {
                case let .success(result):
                    print("Message sent, message id: \(result.id)")
                    // TODO: Push Notification implementieren
                case .failure:
                    print("Failed to send message")
                }
            }
        } else {
            print("ChatThreadClient not initialized.")
        }
    }
    
    // TODO: Die Infos übe den identifier und den displayname müssen irgendwie bei der Implementierung in Erfahrung gebracht und übergeben werden
    private func addParticipant(identifier: String, displayName: String) {
        self.getParticipants { participants in
            let id = CommunicationUserIdentifier(identifier)
            if let participants = participants, participants.contains(where: { ($0.id as? CommunicationUserIdentifier)?.identifier ?? "" == id.identifier }) {
                /// participant already exists
                print("Participant already exists.")
            } else {
                /// Add participant
                let user = ChatParticipant(
                    id: id,
                    displayName: displayName
                )

                self.chatThreadClient?.add(participants: [user]) { result, _ in
                    switch result {
                    case let .success(result):
                        result.invalidParticipants == nil ? print("Added participant") : print("Error while adding participant")
                    case .failure:
                        print("Failed to add the participant")
                    }
                }
            }
        }
    }
    
    private func getParticipants(completion: @escaping ([ChatParticipant]?) -> Void) {
        self.chatThreadClient?.listParticipants { result, _ in
            switch result {
            case let .success(participantsResult):
                guard let participants = participantsResult.pageItems else {
                    print("No participants returned.")
                    return completion(nil)
                }
                return completion(participants)
            case .failure:
                print("Failed to list participants")
                completion(nil)
            }
        }
    }
    
    // TODO: Sinnvoll oder überflüssig?
    public func sendReadReceipt(for messageId: Int) {
    }
}
