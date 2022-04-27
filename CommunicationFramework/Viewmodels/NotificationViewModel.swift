//
//  NotificationViewModel.swift
//  CommunicationFramework
//
//  Created by Conrad Felgentreff on 25.04.22.
//

import Combine
import UserNotifications
import WindowsAzureMessaging

public class NotificationViewModel: NSObject, ObservableObject, UNUserNotificationCenterDelegate, MSNotificationHubDelegate, MSInstallationLifecycleDelegate {
    
    public static var shared: NotificationViewModel = NotificationViewModel()
    
    private var notificationPresentationCompletionHandler: Any?
    private var notificationResponseCompletionHandler: Any?

    @Published public var installationId: String = MSNotificationHub.getInstallationId()
    @Published public var pushChannel: String = MSNotificationHub.getPushChannel()
    @Published public var items = [MSNotificationHubMessage]()
    @Published public var tags = MSNotificationHub.getTags()
    @Published public var userId = MSNotificationHub.getUserId()

    let messageReceived = NotificationCenter.default
                .publisher(for: NSNotification.Name("MessageReceived"))

    let messageTapped = NotificationCenter.default
                .publisher(for: NSNotification.Name("MessageTapped"))
    
    override private init() {
        super.init()
    }

    public func connectToHub() {
        let hubName = CommunicationFrameworkHelper.hubName
        let connectionString = CommunicationFrameworkHelper.hubConnectionUrl
        
        if !connectionString.isEmpty && !hubName.isEmpty {
            UNUserNotificationCenter.current().delegate = self;
            MSNotificationHub.setLifecycleDelegate(self)
            MSNotificationHub.setDelegate(self)
            MSNotificationHub.start(connectionString: connectionString, hubName: hubName)
            
            print("connected to notification hub")
            self.addTags()
        }
    }

    public func setUserId() {
        MSNotificationHub.setUserId(self.userId)
    }

    private func addTags() {
        // Get language and country code for common tag values
        let language = Bundle.main.preferredLocalizations.first ?? "<undefined>"
        let countryCode = NSLocale.current.regionCode ?? "<undefined>"

        // Create tags with type_value format
        let languageTag = "language_" + language
        let countryCodeTag = "country_" + countryCode

        MSNotificationHub.addTags([languageTag, countryCodeTag])
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        self.notificationPresentationCompletionHandler = completionHandler
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        self.notificationResponseCompletionHandler = completionHandler
    }


    public func notificationHub(_ notificationHub: MSNotificationHub, didSave installation: MSInstallation) {
        DispatchQueue.main.async {
            self.installationId = installation.installationId
            self.pushChannel = installation.pushChannel
            print("notificationHub installation was successful.")
        }
    }

    public func notificationHub(_ notificationHub: MSNotificationHub!, didFailToSave installation: MSInstallation!, withError error: Error!) {
        print("notificationHub installation failed.")
    }

    public func notificationHub(_ notificationHub: MSNotificationHub, didReceivePushNotification message: MSNotificationHubMessage) {

        let userInfo = ["message": message]

        // Append receivedPushNotification message to self.items
        self.items.append(message)

        if (self.notificationResponseCompletionHandler != nil) {
            NSLog("Tapped Notification")
            NotificationCenter.default.post(name: NSNotification.Name("MessageTapped"), object: nil, userInfo: userInfo)
        } else {
            NSLog("Notification received in the foreground")
            NotificationCenter.default.post(name: NSNotification.Name("MessageReceived"), object: nil, userInfo: userInfo)
        }

        // Call notification completion handlers.
        if (self.notificationResponseCompletionHandler != nil) {
            (notificationResponseCompletionHandler as! () -> Void)()
            notificationResponseCompletionHandler = nil
        }
        if (self.notificationPresentationCompletionHandler != nil) {
            (notificationPresentationCompletionHandler as! (UNNotificationPresentationOptions) -> Void)([])
            notificationPresentationCompletionHandler = nil
        }
    }

}

