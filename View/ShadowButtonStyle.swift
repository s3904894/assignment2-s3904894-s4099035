//
//  buttonBody.swift
//  Habood
//
//  Created by Stephan Karatselios on 28/8/2025.
//

// ShadowButtonStyle.swift
import SwiftUI

struct ShadowButtonStyle: ButtonStyle {
    var cornerRadius: CGFloat = 16
    var padding: CGFloat = 14

    @Environment(\.colorScheme) private var scheme

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        let bg = Color(uiColor: scheme == .dark ? .secondarySystemBackground : .systemBackground)
        let fg = Color.primary
        let shadow = scheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.15)
        let y: CGFloat = isPressed ? 2 : 5
        let r: CGFloat = isPressed ? 6 : 12

        configuration.label
            .foregroundStyle(fg)
            .padding(padding)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(bg)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(.separator, lineWidth: 0.5)
            )
            .shadow(color: shadow, radius: r, x: 0, y: y)
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.18), value: isPressed)
    }
}

