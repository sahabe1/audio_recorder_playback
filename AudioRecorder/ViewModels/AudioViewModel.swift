//
//  AudioViewModel.swift
//  AudioRecorder
//
//  Created by Sahabe Alam on 13/03/24.
//

import Foundation
import AVFoundation
import SwiftUI

class AudioViewModel:NSObject, ObservableObject, AVAudioPlayerDelegate {
    
    private var audioRecorder : AVAudioRecorder?
    private var audioPlayer : AVAudioPlayer?
    private let recordingSession = AVAudioSession.sharedInstance()
    
    @Published var isRecording : Bool = false
    @Published private var countSec = 0
    @Published private var timerCount : Timer?
    @Published var timer : String = "0:00"
    @Published var playingStatus : PlayingStatus = .none
    @Published var progress: Float = 0.0
    var isMicPermissionEnabled : Bool = false
    
    var playingURL : URL?
    
    override init() {
        super.init()
        setupAudioRecorder()
        
    }
    var title: String{
        switch playingStatus {
        case .playing:
            return ButtonTitleConstants.pause
        case .pause:
            return ButtonTitleConstants.play
        case .stop:
            return ButtonTitleConstants.play
        case .none:
            return ButtonTitleConstants.play
        }
    }
    
    private func setupAudioRecorder() {
        do {
            try self.recordingSession.setCategory(.playAndRecord, mode: .default)
            try self.recordingSession.setActive(true)
        } catch {
            print("Cannot setup the Recording \(error.localizedDescription)")
        }
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        // Create Unique File name for preventing current file by adding datetime stamp in the file name or something else
        let fileName = path.appendingPathComponent(Constants.fileName)
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do {
            self.audioRecorder = try AVAudioRecorder(url: fileName, settings: settings)
            self.audioRecorder?.isMeteringEnabled = true
            self.audioRecorder?.prepareToRecord()
            self.audioRecorder?.record()
            
        } catch {
            print("Failed to Setup the Recording")
        }
        fetchRecordingPath()
    }
    
    func startRecording() {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            self.audioRecorder?.record()
            self.isRecording = true
            self.updateProgress()
            self.timer = "0:00"
            self.timerCount = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (value) in
                self.countSec += 1
                self.timer = self.covertSecToMinAndHour(seconds: self.countSec)
            })
        } catch {
            print("Error starting recording: \(error.localizedDescription)")
        }
        
        
    }
    private func updateProgress() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if self.isRecording {
                self.audioRecorder?.updateMeters()
                let normalizedValue = pow(2, (self.audioRecorder?.averagePower(forChannel: 0) ?? 0) / 30)
                self.progress = Float(normalizedValue)
                print(normalizedValue)
            } else {
                timer.invalidate()
            }
        }
    }
    func stopRecording(){
        audioRecorder?.stop()
            isRecording = false
            self.countSec = 0
        timerCount?.invalidate()
       
        
        
    }
    // MARK: Not Tested seem required real device
    func setMicOptions(micOptions: MicOption){
        guard let inputs = recordingSession.availableInputs else{
            return
        }
        print(inputs.debugDescription)
        for input in inputs{
            print(input.dataSources ?? "")
        }
        // set preferred:
        let preferredPort = inputs[0]
        if let dataSources = preferredPort.dataSources{
            for source in dataSources {
                if source.dataSourceName.lowercased() == micOptions.rawValue.lowercased() {
                    do {
                        try preferredPort.setPreferredDataSource(source)
                    }catch _ {
                        print("cannot set frontDataSource")
                    }
                }
            }
        }
    }
    private func fetchRecordingPath(){
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directoryContents = try! FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)
        self.playingURL = directoryContents.first
        
        
    }
    func startPlaying(url : URL) {
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            playingStatus = .playing
            
        } catch{
            print("Playing Failed \(error.localizedDescription)")
        }
    }
    
    func stopPlaying() {
        playingStatus = .stop
        audioPlayer?.stop()
    }
    func pausePlaying() {
        audioPlayer?.pause()
        playingStatus = .pause
    }
    func restartPlaying() {
        playingStatus = .playing
        audioPlayer?.play()
    }

    func checkAndRequestMicPermission() {
            switch AVAudioSession.sharedInstance().recordPermission {
            case AVAudioSession.RecordPermission.granted:
                self.isMicPermissionEnabled = true
            case AVAudioSession.RecordPermission.denied:
                self.isMicPermissionEnabled = false
            case AVAudioSession.RecordPermission.undetermined:
                AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                    if granted {
                        self.isMicPermissionEnabled = true
                       
                    } else {
                        self.isMicPermissionEnabled = false
                    }
                })
            default:
                break
            }
        
        
        
    }
}

extension AudioViewModel{
    func covertSecToMinAndHour(seconds : Int) -> String{
        let (_,m,s) = (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
        let sec : String = s < 10 ? "0\(s)" : "\(s)"
        return "\(m):\(sec)"
        
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playingStatus = .stop
        
    }
}

