//
//  PlayerButton.swift
//  AudioRecorder
//
//  Created by Sahabe Alam on 13/03/24.
//

import SwiftUI

struct PlayerButton: View {
    var title: String
    var isDisabled = false
    let action: () -> Void
    var body: some View{
        Button(title, action: action).buttonStyle(CustomButtonStyle(isDisable: isDisabled))
    }
}

#Preview {
    PlayerButton(title: "Test", action: {})
}
