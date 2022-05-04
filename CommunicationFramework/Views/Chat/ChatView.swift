//
//  ChatView.swift
//  CommunicationFramework
//
//  Created by Conrad Felgentreff on 29.04.22.
//

import SwiftUI

struct ChatView: View {
    
    @EnvironmentObject var chatViewModel: ChatViewModel
    
    @State private var message = ""
    private var dates: [Date] {
        var dates: [Date] = []
        for message in self.chatViewModel.messages {
            if !dates.contains(where: { $0.isSameDay(as: message.createdOn) }) {
                print(message.createdOn)
                dates.append(message.createdOn)
            }
        }
        return dates.sorted { $0.compare($1) == .orderedAscending }
    }
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            if !self.chatViewModel.loadedMessages {
                
                ScrollView {
                    
                    ScrollViewReader { value in
                        
                        VStack(spacing: 10) {
                            
                            ForEach(self.dates, id: \.self) { date in
                                
                                Divider()
                                    .padding(.top)
                                
                                Text(date.dateString)
                                    .font(.system(size: 18))
                                    .foregroundColor(Color(.systemGray2))
                                
                                ForEach(self.chatViewModel.messages.filter { $0.createdOn.isSameDay(as: date) }.sorted { $0.createdOn.compare($1.createdOn) == .orderedAscending }) { message in
                                    
                                    MessageView(chatMessage: message)
                                        .id(message.id)
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .onChange(of: self.chatViewModel.messages.count) { _ in
                            withAnimation {
                                value.scrollTo(self.chatViewModel.messages.sorted { $0.createdOn.compare($1.createdOn) == .orderedAscending }.last?.id)
                            }
                        }
                        .onAppear {
                            value.scrollTo(self.chatViewModel.messages.sorted { $0.createdOn.compare($1.createdOn) == .orderedAscending }.last?.id)
                        }
                    }
                }
            } else {
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            HStack(spacing: 15) {
                
                TextField("Schreibe eine Nachricht...", text: self.$message)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button {
                    self.chatViewModel.sendMessage(text: self.message.trimmingCharacters(in: .whitespacesAndNewlines))
                    self.message = ""
                } label: {
                    
                    Text("Senden")
                        .bold()
                        .foregroundColor(.white)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 15).foregroundColor(.blue))
                }
                .disabled(self.message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(self.message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
            }
            .padding()
            .background(
                Color(.systemGray4)
                    .shadow(radius: 5)
                    .edgesIgnoringSafeArea(.bottom)
            )
        }
        .background(Color(.systemGray6))
        .navigationBarTitle("Chat mit \(self.chatViewModel.chatPartnerName ?? "")", displayMode: .inline)
        .onAppear {
            print(UIScrollView.appearance().keyboardDismissMode.rawValue)
            UIScrollView.appearance().keyboardDismissMode = .onDrag
        }
        .onDisappear {
            UIScrollView.appearance().keyboardDismissMode = .interactive
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
            .environmentObject(ChatViewModel.shared)
    }
}
