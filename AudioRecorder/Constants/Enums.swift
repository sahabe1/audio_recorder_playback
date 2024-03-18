//
//  Enums.swift
//  AudioRecorder
//
//  Created by Sahabe Alam on 13/03/24.
//

import Foundation

enum PlayingStatus{
    case playing
    case pause
    case stop
    case none
}

enum MicOption: String,CaseIterable {
    case top = "Top"
    case bottom = "Bottom"
    case back = "Back"
    case front = "Front"
}

