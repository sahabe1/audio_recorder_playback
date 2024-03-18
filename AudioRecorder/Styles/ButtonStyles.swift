//
//  ButtonStyles.swift
//  AudioRecorder
//
//  Created by Sahabe Alam on 13/03/24.
//

import SwiftUI

struct CustomButtonStyle: ButtonStyle {
    var isDisable = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 100)
            .padding()
            .font(.title2)
            .background(isDisable ? Color.gray : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .opacity(configuration.isPressed ? 0.5 : 1)
    }
}
