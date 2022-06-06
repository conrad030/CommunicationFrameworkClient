//
//  CallingModelDelegate.swift
//  CommunicationFramework
//
//  Created by Conrad Felgentreff on 01.06.22.
//

import SwiftUI

protocol CallingModelDelegate {
    func pushNotificationsRegistered()
    func toggleMuteSucceeded(with mute: Bool)
    func toggleVideoSucceeded(with videoOn: Bool)
    func onCallStarted()
    func onCallEnded()
}
