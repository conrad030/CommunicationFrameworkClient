//
//  MessageView.swift
//  CommunicationFramework
//
//  Created by Conrad Felgentreff on 29.04.22.
//

import SwiftUI

struct MessageView: View {
    
    var chatMessage: ChatMessage
    private var isOwnMessage: Bool {
        self.chatMessage.senderIdentifier == CommunicationFrameworkHelper.id
    }
    private let cornerRadius: CGFloat = 15
    
    var body: some View {
        
        HStack {
            
            if self.isOwnMessage {
                
                Spacer(minLength: 0)
            }
            
            HStack(spacing: 15) {
                
                Text(self.chatMessage.message)
                    .font(.system(size: 17))
                
                Text(self.chatMessage.createdOn.timeString)
                    .font(.system(size: 13))
                    .opacity(0.5)
            }
            .padding(10)
            .foregroundColor(self.isOwnMessage ? .black : .white)
            .background(
                RoundedCorners(color: self.isOwnMessage ? Color(.systemGray4) : .blue, tl: self.cornerRadius, tr: self.cornerRadius, bl: self.isOwnMessage ? self.cornerRadius : 0, br: self.isOwnMessage ? 0 : self.cornerRadius)
                    .shadow(radius: 3)
            )
            
            
            if !self.isOwnMessage {
                
                Spacer(minLength: 0)
            }
        }
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView(chatMessage: ChatMessage(senderIdentifier: UUID().uuidString, sender: "Me", message: "Test message", createdOn: Date()))
    }
}
