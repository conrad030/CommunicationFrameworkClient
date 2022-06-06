//
//  StreamView.swift
//  CommunicationFramework
//
//  Created by Conrad Felgentreff on 02.06.22.
//

import SwiftUI

struct StreamView: View {
    
    @EnvironmentObject var callingViewModel: CallingViewModel
    
    var body: some View {
        
        ZStack {
            
            if let videoStreamView = self.callingViewModel.remoteVideoStreamModel?.videoStreamView {
                
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
                    
                    Text(self.callingViewModel.displayName ?? "Anonymus")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                    
                    Image(systemName: self.callingViewModel.isMuted ? "speaker.slash" : "speaker.wave.2")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                        .padding()
                    
                    Spacer()
                }
                .padding(.top, 30)
                
                Spacer()
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct StreamView_Previews: PreviewProvider {
    static var previews: some View {
        StreamView()
    }
}
