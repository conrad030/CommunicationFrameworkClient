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
    
    @StateObject private var callingViewModel: CallingViewModel = CallingViewModel(callingModel: AzureCallingModel())
    @StateObject private var chatViewModel: ChatViewModel = ChatViewModel(chatModel: AzureChatModel())
    
    init() {
        /// Init notification hub credentials
        let hubName = getPlistInfo(resourceName: "Info", key: "HUBNAME")
        let hubUrl = getPlistInfo(resourceName: "Info", key: "HUBCONNECTIONURL")
        
        CommunicationFrameworkHelper.initNotificationHubCredentials(hubName: hubName, hubConnectionUrl: hubUrl)
        
        /// Init ACS enpoint
        let acsEndpoint = getPlistInfo(resourceName: "Info", key: "ACSENDPOINT")
        
        CommunicationFrameworkHelper.initACSEndpoint(endpoint: acsEndpoint)
    }
    
    var body: some Scene {
        
        WindowGroup {
            
            ContentView()
                .environmentObject(self.callingViewModel)
                .environmentObject(self.chatViewModel)
        }
    }
}
