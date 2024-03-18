//
//  ContentView.swift
//  AudioRecorder
//
//  Created by Sahabe Alam on 12/03/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var playViewModel = AudioViewModel()
    @State private var showAlert = false
    @State private var showMicOptions = false
    @Environment(\.scenePhase) var scenePhase
    var body: some View {
        
        VStack(alignment: .center, spacing:20) {
            HStack(spacing: 10) {
                Spacer()
                Button{
                    showMicOptions = true
                }label: {
                    Image(systemName: "ellipsis").font(.system(size: 30))
                }.confirmationDialog(Constants.micOptionTitle, isPresented: $showMicOptions, titleVisibility: .visible) {
                    ForEach(MicOption.allCases, id: \.self) { option in
                        Button(option.rawValue) {
                            playViewModel.setMicOptions(micOptions: option)
                        }
                    }
                    
                }
            }
            Text(Constants.title).multilineTextAlignment(.center).font(.title2)
            ProgressView(value: playViewModel.progress)
                .padding()
                .opacity(playViewModel.isRecording ? 1 : 0)
            
            Text(playViewModel.timer)
                .font(.system(size:60))
                .foregroundColor(.black)
            PlayerButton(title: playViewModel.isRecording ? ButtonTitleConstants.stop: ButtonTitleConstants.record) {
                if (playViewModel.isRecording){
                    playViewModel.stopRecording()
                } else{
                    if playViewModel.isMicPermissionEnabled {
                        playViewModel.startRecording()
                    } else{
                        showAlert = true
                    }
                    
                }
            }.alert(Constants.permissionTitle, isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(Constants.permissionmessage)
            }
            
            
            PlayerButton(title: playViewModel.title,isDisabled: playViewModel.isRecording) {
                if let url = playViewModel.playingURL{
                    switch(playViewModel.playingStatus){
                    case .none,.stop:
                        playViewModel.startPlaying(url: url)
                    case .playing:
                        playViewModel.pausePlaying()
                    case .pause:
                        playViewModel.restartPlaying()
                        
                    }
                }
            }
            Spacer()
        }.onChange(of: scenePhase) { newPhase in
            if(newPhase == .background){
                //                playViewModel.stopRecording() // Uncomment this line to prevent recording from background
            }
        }.onAppear{
            playViewModel.checkAndRequestMicPermission()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
