//
//  StreamView.swift
//  CommunicationFramework
//
//  Created by Conrad Felgentreff on 22.04.22.
//

import SwiftUI
import AzureCommunicationCalling

struct StreamViewOld: View {
    @StateObject var remoteVideoStreamModel: AzureRemoteVideoStreamModel
    @State var isMicrophoneMuted:Bool = false
    @State var isSpeaking:Bool = false

    var body: some View {
        
        ZStack {
            
            if let videoStreamView = self.remoteVideoStreamModel.videoStreamView {
                
                videoStreamView
            } else {
                
                // TODO: Wenn Video disabled wird, muss es anders dargestellt werden
                
                Rectangle()
                    .foregroundColor(.black)
                    .edgesIgnoringSafeArea(.all)
                
                Text("Initializing video...")
                    .foregroundColor(.white)
            }
            
            VStack {
                
                HStack {
                    
                    Spacer()
                    
                    Text(self.remoteVideoStreamModel.displayName)
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                    
                    Image(systemName: self.isMicrophoneMuted ? "speaker.slash" : "speaker.wave.2")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                        .padding()
                    
                    Spacer()
                }
                .padding(.top, 30)
                
                Spacer()
            }
        }
//        .onTapGesture(count: 2) {
//            self.remoteVideoStreamModel.toggleScalingMode()
//        }
        .edgesIgnoringSafeArea(.all)
        .onReceive(self.remoteVideoStreamModel.$isMicrophoneMuted, perform: { isMicrophoneMuted in
            self.isMicrophoneMuted = isMicrophoneMuted
            print("isMicrophoneMuted: \(isMicrophoneMuted)")
        })
        .onReceive(self.remoteVideoStreamModel.$isSpeaking, perform: { isSpeaking in
            self.isSpeaking = isSpeaking
            print("isSpeaking: \(isSpeaking)")
        })
        .onAppear {
            self.remoteVideoStreamModel.checkStream()
        }
    }
}
