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
    
    @State private var presentCallView = false
    
    var body: some View {
        
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
        .onReceive(self.callingViewModel.$callState) {
            self.presentCallView = $0 == .connected
        }
        .onAppear {
            // TODO: Darf erst initialisiert werden, wenn Credentials gesetzt wurden. Bessere Lösung finden.
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.callingViewModel.initCallAgent()
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
