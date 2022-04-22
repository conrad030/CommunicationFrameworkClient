//
//  VideoStreamView.swift
//  CommunicationFramework
//
//  Created by Conrad Felgentreff on 21.04.22.
//

import SwiftUI
import AzureCommunicationCalling

struct VideoStreamView: UIViewRepresentable {
    
    public let view: RendererView

    func makeUIView(context: Context) -> UIView {
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
    }
}

