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
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var callingViewModel: CallingViewModel = CallingViewModel.shared
    @StateObject private var chatViewModel: ChatViewModel = ChatViewModel.shared
    
    init() {
        /// Init notification hub credentials
        let hubName = getPlistInfo(resourceName: "Info", key: "HUBNAME")
        let hubUrl = getPlistInfo(resourceName: "Info", key: "HUBCONNECTIONURL")
        
        CommunicationFrameworkHelper.initNotificationHubCredentials(hubName: hubName, hubConnectionUrl: hubUrl)
        
        /// Init ACS enpoint
        let acsEndpoint = getPlistInfo(resourceName: "Info", key: "ACSENDPOINT")
        
        CommunicationFrameworkHelper.initACSEndpoint(endpoint: acsEndpoint)
        
        /// Get identifier and token from Server
        let domain = getPlistInfo(resourceName: "Info", key: "DOMAIN")
        let endpoint = getPlistInfo(resourceName: "Info", key: "ENDPOINT")
        let query = getPlistInfo(resourceName: "Info", key: "QUERY")
        
        let defaults = UserDefaults.standard
        var urlString = domain + endpoint
        // If there is an existing identifier, refresh token instead of creating a new identity
        if let identifier = defaults.string(forKey: "identifier") {
            urlString += query + identifier
        }
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.setValue(getPlistInfo(resourceName: "Info", key: "API_KEY"), forHTTPHeaderField: "API-Key")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error with fetching credentials: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Error with the response, unexpected status code: \(String(describing: response))")
                return
            }
            
            if let data = data {
                do {
                    guard let credentials = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] else { return print("Couldn't decode credentials from data") }
                    let displayName = "Conrad"
                    let token = credentials["token"]!
                    let identifier = credentials["identifier"]!
                    // Store identifier in user defaults
                    defaults.set(identifier, forKey: "identifier")
                    /// Init user token credentials
                    CommunicationFrameworkHelper.initUserTokenCredentials(displayName: displayName, token: token, id: identifier)
                    CallingViewModel.shared.initCallAgent()
                    ChatViewModel.shared.initChatViewModel()
                } catch {
                    print("There was an error while trying to decode credentials: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }
    
    var body: some Scene {
        
        WindowGroup {
            
            ContentView()
                .environmentObject(self.callingViewModel)
                .environmentObject(self.chatViewModel)
        }
    }
}
