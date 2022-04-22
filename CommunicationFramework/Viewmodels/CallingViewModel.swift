//
//  CallingViewmodel.swift
//  CommunicationFramework
//
//  Created by Conrad Felgentreff on 21.04.22.
//

// MARK: Viewmodel for managing calls. Singleton, so the object can be accessed in other classes

import SwiftUI
import AVFoundation
import AzureCommunicationCalling
import CallKit

public class CallingViewModel: NSObject, ObservableObject {
    
    /// The singleton instance of this class
    public static let shared: CallingViewModel = CallingViewModel()
    
    private var callClient: CallClient = CallClient()
    private var callAgent: CallAgent?
    private var call: Call?
    private var deviceManager: DeviceManager?
    private var incomingCall: IncomingCall?
    private var voipToken: Data?
    private var localVideoStreams: [LocalVideoStream]?
    
    @Published public var callState: CallState = CallState.none
    @Published public var localVideoStreamModel: LocalVideoStreamModel?
    @Published public var remoteVideoStreamModels: [RemoteVideoStreamModel] = []
    @Published public var incomingCallPushNotification: PushNotificationInfo?
    @Published public var isMicrophoneMuted: Bool = false
    
    public var hasCallAgent: Bool {
        self.callAgent != nil
    }
    
    public var isLocalVideoStreamEnabled: Bool {
        self.localVideoStreamModel != nil
    }
    
    private var hasIncomingCall: ((Bool) -> Void)?
    
    override private init() {
        super.init()
    }
    
    public func setVoipToken(token: Data?) {
        self.voipToken = token
    }
    
    private func initCallAgent(communicationUserTokenModel: CommunicationUserTokenModel, displayName: String?, completion: @escaping (Bool) -> Void) {
        if let communicationUserId = communicationUserTokenModel.communicationUserId,
           let token = communicationUserTokenModel.token {
            do {
                let communicationTokenCredential = try CommunicationTokenCredential(token: token)
                let callAgentOptions = CallAgentOptions()
                callAgentOptions.displayName = displayName ?? communicationUserId
                self.callClient.createCallAgent(userCredential: communicationTokenCredential, options: callAgentOptions) { (callAgent, error) in
                    print("CallAgent successfully created.\n")
                    if self.callAgent != nil {
                        print("\nsomething went wrhong with lifecycle.\n")
                        self.callAgent?.delegate = nil
                    }
                    self.callAgent = callAgent
                    self.callAgent?.delegate = self
                    
                    if let token = self.voipToken {
                        self.registerPushNotifications(voipToken: token)
                    }

                    ProviderDelegate.shared.acceptCall = { callId in
                        self.acceptIncomingCall(callId: callId)
                    }

                    ProviderDelegate.shared.endCall = { callId in
                        self.endCall(callId: callId)
                    }

                    ProviderDelegate.shared.muteCall = { callId in
                        self.toggleMute(callId: callId)
                    }
                    completion(true)
                }
            } catch {
                print("Error: \(error.localizedDescription)")
                completion(false)
            }
        } else {
            print("Invalid communicationUserTokenModel.\n")
        }
    }
    
    /// Register push notifications with voip token
    private func registerPushNotifications(voipToken: Data) {
        self.callAgent?.registerPushNotifications(deviceToken: voipToken, completionHandler: { (error) in
            if(error == nil) {
                print("Successfully registered to VoIP push notification.\n")
            } else {
                print("Failed to register VoIP push notification.\(String(describing: error))\n")
            }
        })
    }
    
    /// Handle an icoming call push notification
    // TODO: Herausfinden, wieso diese Methode wichtig ist. Wozu callAgent.handlePush?
    public func handlePushNotification(incomingCallPushNotification: PushNotificationInfo) {
        if let callAgent = self.callAgent {
            print("CallAgent found.\n")
            callAgent.handlePush(notification: incomingCallPushNotification, completionHandler: { error in
                self.handlePushCompletion(error: error)
            })
        } else {
            print("CallAgent not found.\nConnecting to Communication Services...\n")

            if CommunicationFrameworkHelper.credentialsExist {
                let communicationUserToken = CommunicationUserTokenModel(token: CommunicationFrameworkHelper.token, expiresOn: nil, communicationUserId: CommunicationFrameworkHelper.id)
                self.initCallAgent(communicationUserTokenModel: communicationUserToken, displayName: CommunicationFrameworkHelper.displayName) { success in
                    if success {
                        self.callAgent?.handlePush(notification: incomingCallPushNotification) { error in
                            self.handlePushCompletion(error: error)
                        }
                    } else {
                        print("initCallAgent failed.\n")
                    }
                }
            } else {
                print("Missing credentials!")
            }

        }
    }
    
    /// Handle push completion for callAgent
    private func handlePushCompletion(error: Error?) {
        if let error = error {
            print("Handle push notification failed: \(error.localizedDescription)\n")
        } else {
            print("Handle push notification succeeded.\n")
        }
    }
    
    /// Get call for id
    func getCall(callId: UUID) -> Call? {
        if let call = self.call, call.id == callId.uuidString.lowercased() {
                return call
        } else {
            return nil
        }
    }
    
    /// Get incoming call for id
    func getIncomingCall(callId: UUID) -> IncomingCall? {
        if let call = self.incomingCall, call.id == callId.uuidString.lowercased() {
                return call
        } else {
            return nil
        }
    }
    
    /// Starts a call
    public func startCall() {
        self.requestAudioPermission { success in
            if !success {
                print("Audio permission denied.")
                return
            }
            
            if let callAgent = self.callAgent {
                let callees: [CommunicationUserIdentifier] = [CommunicationUserIdentifier(self.callee)]
                let startCallOptions = StartCallOptions()

                self.getDeviceManager { _ in
                    if let localVideoStreams = self.localVideoStreams {
                        let videoOptions = VideoOptions(localVideoStreams: localVideoStreams)
                        startCallOptions.videoOptions = videoOptions

                        callAgent.startCall(participants: callees, options: startCallOptions) { call, error in
                            if error != nil {
                                print("Failed to start call")
                            } else {
                                print("Successfully started call")
                                self.call = call
                                
                                self.call?.delegate = self
                                
                                self.startVideo(call: self.call!, localVideoStream: localVideoStreams.first!)
                                let callId = UUID(uuidString: (self.call?.id)!)
                                CallController.shared.startCall(callId: callId!, handle: Constants.displayName, isVideo: true) { error in
                                    if let error = error {
                                        print("Outgoing call failed: \(error.localizedDescription)")
                                    } else {
                                        print("outgoing call started.")
                                    }
                                }
                            }
                        }
                    } else {
                        callAgent.startCall(participants: callees, options: startCallOptions) { call, error in
                            if error != nil {
                                print("Failed to start call")
                            } else {
                                print("Successfully started call")
                                self.call = call
                                
                                self.call?.delegate = self
                                let callId = UUID(uuidString: (self.call?.id)!)
                                CallController.shared.startCall(callId: callId!, handle: Constants.displayName, isVideo: true) { error in
                                    if let error = error {
                                        print("Outgoing call failed: \(error.localizedDescription)")
                                    } else {
                                        print("outgoing call started.")
                                    }
                                }
                            }
                        }
                        print("outgoing call started.")
                    }
                }
            } else {
                print("callAgent not initialized.\n")
            }
        }
    }
    
    /// Accepts an incoming call
    public func acceptIncomingCall() {
    }
    
    /// Stops a call
    public func endCall() {
    }
    
    /// Toggle mute in a session
    public func toggleMute() {
        if let call = self.call, let callUUID = UUID(uuidString: call.id) {
            CallController.shared.setMutedCall(callId: callUUID, muted: !self.isMicrophoneMuted) { error in
                if let error = error {
                    print("Failed to setMutedCall: \(error.localizedDescription)\n")
                } else {
                    print("setMutedCall \(!self.isMicrophoneMuted) successfully.\n")
                }
            }
        }
    }
    
    /// Mutes the audio in a session
    private func mute() {
    }
    
    /// Unmutes the audio in a session
    private func unmute() {
    }
    
    /// Toggle video in a session
    public func toggleVideo() {
    }
    
    /// Stops the video in a session
    private func stopVideo() {
    }
    
    /// Starts the video in a session
    private func startVideo() {
    }
    
    // - MARK: Callback methods for CallKit
    
    /// Accepts an incoming call
    private func acceptIncomingCall(callId: UUID) {
        print("AcceptCall requested from CallKit.\n")
        if let _ = self.callAgent,
           let call = self.getIncomingCall(callId: callId) {
            self.requestAudioPermission { authorized in
                if authorized {
                    let acceptCallOptions = AcceptCallOptions()
                    self.getDeviceManager { _ in
                        if let localVideoStreams = self.localVideoStreams {
                            let videoOptions = VideoOptions(localVideoStreams: localVideoStreams)
                            acceptCallOptions.videoOptions = videoOptions
                            call.accept(options: acceptCallOptions) { (call, error) in
                                if error == nil {
                                    print("Incoming call accepted")
                                    self.localVideoStreamModel?.createView(localVideoStream: localVideoStreams.first!)
                                } else {
                                    print("Failed to accept incoming call")
                                }
                            }
                        }
                    }
                } else {
                    print("recordPermission not authorized.")
                }
            }
        } else {
            print("Call not found when trying to accept.\n")
            self.hasIncomingCall = { hasIncomingCall in
                if hasIncomingCall == true {
                    self.acceptIncomingCall(callId: callId)
                    // TODO: Warum?
                    self.hasIncomingCall?(false)
                }
            }
        }
    }
    
    private func endCall(callId: UUID) {
        print("EndCall requested from CallKit.\n")
        if let call = self.getCall(callId: callId) {
            call.hangUp(options: HangUpOptions()) { error in
                if let error = error {
                    print("Hangup failed: \(error.localizedDescription).\n")
                } else {
                    print("Hangup succeeded.\n")
                }
            }
        } else {
            print("Call not found when trying to hangup.\n")
        }
    }
    
    private func toggleMute(callId: UUID) {
        print("MuteCall requested from CallKit.\n")
        if let call = self.getCall(callId: callId) {
            if call.isMuted {
                call.unmute(completionHandler:{ (error) in
                    if let error = error {
                        print("Failed to unmute: \(error.localizedDescription)")
                    } else {
                        print("Successfully un-muted")
                        self.isMicrophoneMuted = false
                    }
                })
            } else {
                call.mute(completionHandler: { (error) in
                    if let error = error {
                        print("Failed to mute: \(error.localizedDescription)")
                    } else {
                        print("Successfully muted")
                        self.isMicrophoneMuted = true
                    }
                })
            }
        } else {
            print("Call not found when trying to set mute.\n")
        }
    }
    
    // MARK: - Permission management.

    /// Request for audio permission
    private func requestAudioPermission(completion: @escaping (Bool) -> Void) {
        let audioSession = AVAudioSession.sharedInstance()
        switch audioSession.recordPermission {
        case .undetermined:
            audioSession.requestRecordPermission { granted in
                if granted {
                    completion(true)
                } else {
                    print("User did not grant audio permission")
                    completion(false)
                }
            }
        case .denied:
            print("User did not grant audio permission, it should redirect to Settings")
            completion(false)
        case .granted:
            completion(true)
        @unknown default:
            print("Audio session record permission unknown case detected")
            completion(false)
        }
    }

    /// Request for video permission
    private func requestVideoPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { authorized in
                if authorized {
                    completion(true)
                } else {
                    print("User did not grant video permission")
                    completion(false)
                }
            }
        case .restricted, .denied:
            print("User did not grant video permission, it should redirect to Settings")
            completion(false)
        case .authorized:
            completion(true)
        @unknown default:
            print("AVCaptureDevice authorizationStatus unknown case detected")
            completion(false)
        }
    }
    
    private func getDeviceManager(completion: @escaping (Bool) -> Void) {
        self.requestVideoPermission { success in
            if success {
                self.callClient.getDeviceManager(completionHandler: { (deviceManager, error) in
                    if (error == nil) {
                        print("Got device manager instance")
                        self.deviceManager = deviceManager

                        if let videoDeviceInfo: VideoDeviceInfo = deviceManager?.cameras.first {
                            self.localVideoStreams = [LocalVideoStream]()
                            self.localVideoStreams!.append(LocalVideoStream(camera: videoDeviceInfo))
                            self.localVideoStreamModel = LocalVideoStreamModel(identifier: CommunicationFrameworkHelper.id, displayName: CommunicationFrameworkHelper.displayName)
                            print("LocalVideoStream instance initialized.")
                            completion(true)
                        } else {
                            print("LocalVideoStream instance initialize failed.")
                            completion(false)
                        }
                    } else {
                        print("Failed to get device manager instance: \(String(describing: error))")
                        completion(false)
                    }
                })
            } else {
                print("Permission denied.\n")
                completion(false)
            }
        }
    }
}

// MARK: - CallAgentDelegate
extension CallingViewModel: CallAgentDelegate {
    
    public func callAgent(_ callAgent: CallAgent, didRecieveIncomingCall incomingCall: IncomingCall) {
        print("Incoming call received.")
        self.incomingCall = incomingCall
        // Subscribe to get OnCallEnded event
        self.incomingCall?.delegate = self
    }
    
    public func callAgent(_ callAgent: CallAgent, didUpdateCalls args: CallsUpdatedEventArgs) {
        print("\n---------------")
        print("onCallsUpdated")
        print("---------------\n")

        if let addedCall = args.addedCalls.first {
            print("addedCalls: \(args.addedCalls.count)")
            self.callState = addedCall.state
            self.isMicrophoneMuted = addedCall.isMuted
            self.hasIncomingCall?(true)
        }
        
        print("removedCalls: \(args.removedCalls.count)\n")
        if let call = self.call,
           let removedCall = args.removedCalls.first(where: {$0.id == call.id}),
           let removedCallUUID = UUID(uuidString: removedCall.id) {
            self.callState = removedCall.state
            self.call?.delegate = nil
            self.call = nil
            
            ProviderDelegate.shared.reportCallEnded(callId: removedCallUUID, reason: CXCallEndedReason.remoteEnded)
        } else {
            print("removedCall: \(String(describing: args.removedCalls))")
            if let incomingCallPushNotification = self.incomingCallPushNotification {
                ProviderDelegate.shared.reportCallEnded(callId: incomingCallPushNotification.callId, reason: CXCallEndedReason.remoteEnded)
            }
        }
    }
}

// MARK: - IncomingCallDelegate
extension CallingViewModel: IncomingCallDelegate {
    
    // Event raised when incoming call was not answered
    public func incomingCall(_ incomingCall: IncomingCall, didEnd args: PropertyChangedEventArgs) {
        print("Incoming call was not answered")
        self.incomingCall = nil
    }
}
