//
//  MessageView.swift
//  CommunicationFramework
//
//  Created by Conrad Felgentreff on 29.04.22.
//

import SwiftUI

struct MessageView: View {
    
    @ObservedObject var chatMessage: ChatMessage
    private var isOwnMessage: Bool {
        self.chatMessage.senderIdentifier == CommunicationFrameworkHelper.id
    }
    private let cornerRadius: CGFloat = 15
    @State private var showFileExporter = false
    @State private var showSaveSuccessAlert = false
    @State private var showSaveErrorAlert = false
    
    var body: some View {
        
        ZStack {
            
            Text("")
                .alert(Text("Erfolgreich heruntergeladen"), isPresented: self.$showSaveSuccessAlert) {
                    Button("Ok", role: .cancel) { }
                }
            
            Text("")
                .alert(Text("Fehler"), isPresented: self.$showSaveErrorAlert, actions: {
                    Button("Ok", role: .cancel) { }
                }) {
                    Text("Beim herunterladen ist ein Fehler aufgetreten.")
                }
        }
        
        HStack {
            
            if self.isOwnMessage {
                
                Spacer(minLength: 0)
            }
            
            VStack(spacing: 10) {
                
                if let file = self.chatMessage.file {
                    
                    ZStack {
                        
                        if let data = file.data {
                            
                            Text("")
                                .fileExporter(isPresented: self.$showFileExporter, document: PDFFile(data: data), contentType: .pdf) { result in
                                    switch result {
                                    case .success:
                                        self.showSaveSuccessAlert = true
                                    case .failure(let error):
                                        print("Error while trying to save pdf file: \(error.localizedDescription)")
                                        self.showSaveErrorAlert = true
                                    }
                                }
                        }
                        
                        Button {
                            self.showFileExporter = true
                        } label: {
                            file.view
                        }
                        .frame(width: 200)
                        .disabled(file.type == .jpg || file.data == nil)
                    }
                }
                
                HStack(spacing: 15) {
                    
                    Text(self.chatMessage.message ?? "")
                        .font(.system(size: 17))
                    
                    Text(self.chatMessage.createdOn.timeString)
                        .font(.system(size: 13))
                        .opacity(0.5)
                }
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
        MessageView(chatMessage: ChatMessage())
    }
}
