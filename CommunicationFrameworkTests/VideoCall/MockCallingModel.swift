//
//  MockCallingModel.swift
//  CommunicationFrameworkTests
//
//  Created by Conrad Felgentreff on 24.06.22.
//

import Foundation
import PushKit
@testable import CommunicationFramework

class MockCallingModel: ObservableObject, CallingModel {
    
    var delegate: CallingModelDelegate?
    
    var localVideoStreamModel: VideoStreamModel?
    
    var remoteVideoStreamModel: VideoStreamModel?
    
    var voipToken: Data?
    
    @Published private(set) var initCallingModelCalled = false
    @Published private(set) var registerPushNotificationsCalled = false
    @Published private(set) var acceptIncomingCallCalled = false
    @Published private(set) var endCallWithIdCalled = false
    @Published private(set) var toggleMuteCalled = false
    @Published private(set) var handlePushNotificationCalled = false
    @Published private(set) var startCallCalled = false
    @Published private(set) var endCallCalled = false
    @Published private(set) var muteCalled = false
    @Published private(set) var unmuteCalled = false
    @Published private(set) var startVideoCalled = false
    @Published private(set) var stopVideoCalled = false
    
    func initCallingModel(identifier: String, token: String, displayName: String) {
        self.initCallingModelCalled = true
    }
    
    func registerPushNotifications(voipToken: Data) {
        self.registerPushNotificationsCalled = true
    }
    
    func acceptIncomingCall(callId: UUID) {
        self.acceptIncomingCallCalled = true
    }
    
    func endCall(callId: UUID) {
        self.endCallWithIdCalled = true
    }
    
    func toggleMute(callId: UUID) {
        self.toggleMuteCalled = true
    }
    
    func handlePushNotification(payload: PKPushPayload) {
        self.handlePushNotificationCalled = true
    }
    
    func startCall(calleeIdentifier: String) {
        self.startCallCalled = true
    }
    
    func endCall() {
        self.endCallCalled = true
    }
    
    func mute() {
        self.muteCalled = true
    }
    
    func unmute() {
        self.unmuteCalled = true
    }
    
    func startVideo() {
        self.startCallCalled = true
    }
    
    func stopVideo() {
        self.stopVideoCalled = true
    }
}
