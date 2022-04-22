//
//  CallView.swift
//  CommunicationFramework
//
//  Created by Conrad Felgentreff on 21.04.22.
//

import SwiftUI

struct CallView: View {
    
    @EnvironmentObject var callingViewModel: CallingViewModel

    private var selectedAnchor: Alignment = .topLeading
    
    var body: some View {
        
        GeometryReader { outerGeometry in
            
            ZStack {
                
                if !self.callingViewModel.remoteVideoStreamModels.isEmpty {
                    
                    StreamView(remoteVideoStreamModel: self.callingViewModel.remoteVideoStreamModels.first!)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: outerGeometry.size.width, height: outerGeometry.size.height)
                } else {
                    
                    Rectangle()
                        .edgesIgnoringSafeArea(.all)
                }
                VStack {
                    
                    GeometryReader { geometry in
                        
                        if self.callingViewModel.localVideoStreamModel != nil {
                            
                            self.callingViewModel.localVideoStreamModel?.videoStreamView
                                .cornerRadius(16)
                                .frame(width: geometry.size.width / 3, height: geometry.size.height / 3)
                                .padding([.top, .leading], 30)
                        } else {
                            
                            Rectangle()
                                .cornerRadius(16)
                                .frame(width: geometry.size.width / 3, height: geometry.size.height / 3)
                                .padding([.top, .leading], 30)
                        }
                    }
                    
                    Spacer()
                    
                    HStack {
                        
                        Button {
                            self.callingViewModel.toggleVideo()
                        } label: {
                            HStack {
                                Spacer()
                                if self.callingViewModel.isLocalVideoStreamEnabled {
                                    Image(systemName: "video")
                                        .padding()
                                } else {
                                    Image(systemName: "video.slash")
                                        .padding()
                                }
                                Spacer()
                            }
                        }
                        
                        Button {
                            self.callingViewModel.toggleMute()
                        } label: {
                            
                            HStack {
                                
                                Spacer()
                                
                                if self.callingViewModel.isMicrophoneMuted {
                                    
                                    Image(systemName: "speaker.slash")
                                        .padding()
                                } else {
                                    
                                    Image(systemName: "speaker.wave.2")
                                        .padding()
                                }
                                
                                Spacer()
                            }
                        }
                        
                        Button {
                            self.callingViewModel.endCall()
                        } label: {
                            
                            HStack {
                                
                                Spacer()
                                
                                Image(systemName: "phone.down")
                                    .foregroundColor(.red)
                                    .padding()
                                
                                Spacer()
                            }
                        }
                    }
                }
                .font(.largeTitle)
            }
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
}

struct CallView_Previews: PreviewProvider {
    static var previews: some View {
        CallView()
            .environmentObject(CallingViewModel.shared)
    }
}
