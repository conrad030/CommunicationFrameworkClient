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
            self.callingViewModel.startCall()
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        
        ContentView()
            .environmentObject(CallingViewModel.shared)
    }
}
