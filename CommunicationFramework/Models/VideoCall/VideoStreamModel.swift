//
//  VideoStreamModel.swift
//  CommunicationFramework
//
//  Created by Conrad Felgentreff on 21.04.22.
//

import SwiftUI
import AzureCommunicationCalling

public class VideoStreamModel: NSObject, ObservableObject, Identifiable {
    public var identifier: String
    public var renderer: VideoStreamRenderer?
    @Published var displayName: String
    @Published var videoStreamView: VideoStreamView?

    public init(identifier: String, displayName: String) {
        self.identifier = identifier
        self.displayName = displayName
    }
}
