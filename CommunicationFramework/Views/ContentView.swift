//
//  ContentView.swift
//  CommunicationFramework
//
//  Created by Conrad Felgentreff on 21.04.22.
//

// MARK: Stellvertretend für Client. Wird später noch ausgelagert.

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var callingViewModel: CallingViewModel
    @EnvironmentObject var chatViewModel: ChatViewModel
    
    @State private var presentCallView = false
    @State private var presentChatView = false
    @State private var showChatLoadingIndicator = false
    
    var body: some View {
        
        NavigationView {
            
            VStack(spacing: 20) {
                
                NavigationLink(destination: ChatView().environmentObject(self.chatViewModel), isActive: self.$presentChatView) {
                    Text("")
                }
                
                Button {
                    // TODO: Irgendwo muss man den Identifier herbekommen
                    // iPhone 12: 8:acs:7d8a86e0-5ac4-4d37-a9dd-dabf0f99e29b_00000011-00ed-af4e-65f0-ad3a0d000130
                    // iPhone 6s: 8:acs:7d8a86e0-5ac4-4d37-a9dd-dabf0f99e29b_00000011-00b5-7de7-59fe-ad3a0d00fee0
                    self.callingViewModel.startCall(calleeIdentifier: "8:acs:7d8a86e0-5ac4-4d37-a9dd-dabf0f99e29b_00000011-00b5-7de7-59fe-ad3a0d00fee0")
                } label: {
                    
                    Text("Start call")
                        .bold()
                        .foregroundColor(.white)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 15).foregroundColor(.blue))
                }
                .fullScreenCover(isPresented: self.$presentCallView) {
                    
                    CallView()
                        .environmentObject(self.callingViewModel)
                }
                .disabled(!self.callingViewModel.enableCallButton)
                .opacity(self.callingViewModel.enableCallButton ? 1 : 0.5)
                
                Button {
                    self.showChatLoadingIndicator = true
                    self.chatViewModel.startChat(with: "8:acs:7d8a86e0-5ac4-4d37-a9dd-dabf0f99e29b_00000011-00b5-7de7-59fe-ad3a0d00fee0", displayName: "Conrad iPhone 6s")
                } label: {
                    
                    ZStack {
                        
                        if self.showChatLoadingIndicator {
                            
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            
                            Text("Start chat")
                                .bold()
                                .foregroundColor(.white)
                        }
                    }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 15).foregroundColor(.green))
                }
                .disabled(!self.chatViewModel.enableChatButton)
                .opacity(self.chatViewModel.enableChatButton ? 1 : 0.5)
            }
            .navigationBarTitle("Communication Framework", displayMode: .inline)
        }
        .onReceive(self.callingViewModel.$callState) {
            self.presentCallView = $0 == .connected
        }
        .onReceive(self.chatViewModel.$chatIsSetup) {
            if $0 {
                DispatchQueue.main.async {
                    self.presentChatView = true
                    self.showChatLoadingIndicator = false
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        
        ContentView()
            .environmentObject(CallingViewModel.shared)
    }
}
