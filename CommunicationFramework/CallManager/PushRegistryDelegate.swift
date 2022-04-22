//
//  PushRegistryDelegate.swift
//  CommunicationFramework
//
//  Created by Conrad Felgentreff on 22.04.22.
//

// MARK: To handle incoming push notifications

import PushKit
import AzureCommunicationCalling

public class PushRegistryDelegate: NSObject {
    public static let shared: PushRegistryDelegate = PushRegistryDelegate()
    private let pushRegistry = PKPushRegistry(queue: DispatchQueue.main)

    private override init() {
        super.init()
        ProviderDelegate.shared.configureProvider()
        pushRegistry.delegate = self
        pushRegistry.desiredPushTypes = [.voIP]
    }
}

extension PushRegistryDelegate: PKPushRegistryDelegate {
    
    /// Set the voip token when receiving it via push notification
    public func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        CallingViewModel.shared.setVoipToken(token: pushCredentials.token)
    }

    public func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        print("pushRegistry invalidated: \(type)\n")
    }

    public func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        let dictionaryPayload = payload.dictionaryPayload
        print("dictionaryPayload: \(dictionaryPayload)\n")

        if type == .voIP {
            let incomingCallPushNotification = PushNotificationInfo.fromDictionary(payload.dictionaryPayload)
            let callId = incomingCallPushNotification.callId
            let handle = incomingCallPushNotification.fromDisplayName
            let hasVideo = incomingCallPushNotification.incomingWithVideo
            
            // Report incoming call to ProviderDelegate
            ProviderDelegate.shared.reportNewIncomingCall(callId: callId, handle: handle, hasVideo: hasVideo) { error in
                if let error = error {
                    print("reportNewIncomingCall failed: \(error.localizedDescription)\n")
                } else {
                    print("reportNewIncomingCall was succesful.\n")
                }
                completion()
                
                CallingViewModel.shared.handlePushNotification(incomingCallPushNotification: incomingCallPushNotification)
            }
        }
    }
}
