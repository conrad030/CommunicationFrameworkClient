//
//  CommunicationFrameworkApp.swift
//  CommunicationFramework
//
//  Created by Conrad Felgentreff on 21.04.22.
//

// MARK: Stellvertretend für Client. Wird später noch ausgelagert.

import SwiftUI

@main
struct CommunicationFrameworkApp: App {
    
    @StateObject private var callingViewModel: CallingViewModel = CallingViewModel.shared
    
    init() {
        
    }
    
    var body: some Scene {
        
        WindowGroup {
            
            ContentView()
                .environmentObject(self.callingViewModel)
        }
    }
}
