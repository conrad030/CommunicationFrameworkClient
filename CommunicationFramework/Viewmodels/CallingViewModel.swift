//
//  CallingViewModel.swift
//  CommunicationFramework
//
//  Created by Conrad Felgentreff on 01.06.22.
//

import SwiftUI
import Combine
import PushKit
import AVFoundation

class CallingViewModel: ObservableObject {
    
    /// The singleton instance of this class
    public static let shared: CallingViewModel = CallingViewModel()
    
    @Published private var callingModel: CallingModel
    
    @Published public var displayName: String?
    public var localVideoStreamModel: VideoStreamModel? {
        self.callingModel.localVideoStreamModel
    }
    public var remoteVideoStreamModel: VideoStreamModel? {
        self.callingModel.remoteVideoStreamModel
    }
    @Published public var localeVideoIsOn: Bool = true
    @Published public var remoteVideoIsOn: Bool = false
    @Published public var isMuted: Bool = false
    
    @Published public var enableCallButton: Bool = false
    @Published public var presentCallView: Bool = false
    
    private var anyCancellable: AnyCancellable? = nil
    
    struct Config {
        var callingModel: CallingModel
    }
    
    private static var config: Config?
    
    class func setup<Model: CallingModel & ObservableObject>(callingModel: Model) {
        let config = Config(callingModel: callingModel)
        CallingViewModel.config = config
    }
        
    private init() {
        guard let config = CallingViewModel.config else {
            fatalError("Error: You must call setup before accessing CallingViewModel.shared")
        }
        self.callingModel = config.callingModel
        self.callingModel.delegate = self
        _ = PushRegistryDelegate.shared
        self.initProvider()
        self.requestAudioAndVideoPermission { _ in }
    }
    
    public func linkModelToViewModel<Model: CallingModel & ObservableObject>(callingModel: Model) {
        /// Has to be linked to AnyCancellable, so changes of the ObservableObject are getting detected
        self.anyCancellable = callingModel.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }
    
    public func initCallingViewModel() {
        if !CommunicationFrameworkHelper.id.isEmpty && !CommunicationFrameworkHelper.token.isEmpty && !CommunicationFrameworkHelper.displayName.isEmpty {
            self.displayName = CommunicationFrameworkHelper.displayName
            self.callingModel.initCallingModel(identifier: CommunicationFrameworkHelper.id, token: CommunicationFrameworkHelper.token, displayName: CommunicationFrameworkHelper.displayName)
        } else {
            print("CallingModel couldn't be initialized. Credentials are missing.")
        }
    }
    
    public func setVoipToken(token: Data?) {
        self.callingModel.voipToken = token
    }
    
    public func startCall(identifier: String) {
        self.requestAudioPermission { success in
            if !success {
                print("Audio permission denied.")
                return
            }
            self.requestVideoPermission { success in
                if !success {
                    print("Video permission denied.")
                    return
                }
                
                self.callingModel.startCall(calleeIdentifier: identifier)
            }
        }
    }
    
    public func endCall() {
        self.callingModel.endCall()
    }
    
    public func toggleVideo() {
        if self.localeVideoIsOn {
            self.stopVideo()
        } else {
            self.startVideo()
        }
    }
    
    private func startVideo() {
        self.callingModel.startVideo()
    }
    
    private func stopVideo() {
        self.callingModel.stopVideo()
    }
    
    public func toggleMute() {
        if self.isMuted {
            self.unmute()
        } else {
            self.mute()
        }
    }
    
    private func mute() {
        self.callingModel.mute()
    }
    
    private func unmute() {
        self.callingModel.unmute()
    }
    
    public func handlePushNotification(payload: PKPushPayload) {
        self.callingModel.handlePushNotification(payload: payload)
    }
    
    private func initProvider() {
        ProviderDelegate.shared.acceptCall = { callId in
            self.requestAudioAndVideoPermission { authorized in
                if !authorized {
                    print("Record permissions not denied.")
                    return
                }
                self.callingModel.acceptIncomingCall(callId: callId)
            }
        }

        // TODO: Wird auch aufgerufen, wenn Anruf von Callee beendet wird
        ProviderDelegate.shared.endCall = { callId in
            self.callingModel.endCall(callId: callId)
        }

        ProviderDelegate.shared.muteCall = { callId in
            self.callingModel.toggleMute(callId: callId)
        }
    }
    
    // MARK: - Permission management.

    private func requestAudioAndVideoPermission(completion: @escaping (Bool) -> Void) {
        self.requestAudioPermission { authorized in
            if !authorized {
                return completion(false)
            } else {
                self.requestVideoPermission { authorized in
                    return completion(authorized)
                }
            }
        }
    }
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
}

extension CallingViewModel: CallingModelDelegate {
    
    public func pushNotificationsRegistered() {
        self.enableCallButton = true
    }
    
    public func toggleMuteSucceeded(with mute: Bool) {
        self.isMuted = mute
    }
    
    public func toggleVideoSucceeded(with videoOn: Bool) {
        self.localeVideoIsOn = videoOn
    }
    
    public func onCallStarted() {
        self.presentCallView = true
    }
    
    public func onCallEnded() {
        self.presentCallView = false
    }
}
