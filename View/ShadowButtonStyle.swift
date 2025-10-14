//
//  buttonBody.swift
//  Habood
//
//  Created by Stephan Karatselios on 28/8/2025.
//

import SwiftUI

struct ShadowButtonStyle : ButtonStyle {
    var shadowColor: Color = .black
    var shadowRadius: CGFloat = 10
    var shadowX: CGFloat = 0
    var shadowY: CGFloat = 5
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(
                color: configuration.isPressed ? shadowColor.opacity(0.4): shadowColor.opacity(0.8), radius: configuration.isPressed ? shadowRadius / 2 : shadowRadius, x: shadowX, y: shadowY
            )
            .scaleEffect(configuration.isPressed ? 0.95: 1.0)
            .animation(.easeOut(duration: 0.2), value:configuration.isPressed)
    }
}
