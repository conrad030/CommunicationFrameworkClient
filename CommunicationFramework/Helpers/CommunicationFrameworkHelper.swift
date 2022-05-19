//
//  CommunicationFrameworkHelper.swift
//  CommunicationFramework
//
//  Created by Conrad Felgentreff on 21.04.22.
//

import Foundation

class CommunicationFrameworkHelper {
    
    /// Azure Notification Hub Credentials
    private(set) static var hubName: String = ""
    private(set) static var hubConnectionUrl: String = ""
    
    /// Azure Communication Service Credentials
    private(set) static var endpoint: String = ""
    private(set) static var displayName: String = ""
    private(set) static var token: String = ""
    private(set) static var id: String = ""
    
    /// Returns true, when there are existing credentials
    public static var credentialsExist: Bool {
        !CommunicationFrameworkHelper.hubName.isEmpty && !CommunicationFrameworkHelper.hubConnectionUrl.isEmpty && !CommunicationFrameworkHelper.hubName.isEmpty && !CommunicationFrameworkHelper.displayName.isEmpty && !CommunicationFrameworkHelper.token.isEmpty
    }
    
    /// Set Azure Notification Hub Credentials
    /// - Parameters:
    ///   - hubName: String
    ///   - hubConnectionString: String
    public static func initNotificationHubCredentials(hubName: String, hubConnectionUrl: String) {
        CommunicationFrameworkHelper.hubName = hubName
        CommunicationFrameworkHelper.hubConnectionUrl = hubConnectionUrl
    }
    
    public static func initACSEndpoint(endpoint: String) {
        self.endpoint = endpoint
    }
    
    /// Set Azure Communication Service Credentials
    ///  - Parameters:
    ///     - displayName: String
    ///     - token: String
    public static func initUserTokenCredentials(displayName: String, token: String, id: String) {
        CommunicationFrameworkHelper.displayName = displayName
        CommunicationFrameworkHelper.token = token
        CommunicationFrameworkHelper.id = id
    }
}
