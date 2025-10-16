//
//  ShareSheet.swift
//  Habood
//
//  Created by Yunlong Chen on 2025/10/15.
//

import SwiftUI
import UIKit

/// A UIKit-based share sheet integrated into the SwiftUI app.
///
/// The `ShareSheet` uses Apple’s **UIActivityViewController** to enable sharing
/// of text, links, or images via system apps like Messages, Mail, or Notes.
///
/// This component demonstrates **UIKit and SwiftUI interoperability**, fulfilling
/// the “UIKit feature” requirement for the iPSE assignment.
///
/// - Features:
///   - Integrates UIKit into SwiftUI using `UIViewControllerRepresentable`
///   - Presents a system share sheet for text, images, or URLs
///   - Fully reusable by passing an array of items to share
///
/// Example:
/// ```swift
/// ShareSheet(activityItems: ["Today I feel 😊 Happy with intensity 5/5."])
/// ```
///
/// - Author: Yunlong Chen
struct ShareSheet: UIViewControllerRepresentable {

    // Properties

    /// The list of items to share (text, images, URLs, etc.).
    ///
    /// Example:
    /// ```swift
    /// ShareSheet(activityItems: ["Check out my mood tracker progress!"])
    /// ```
    let activityItems: [Any]

    /// Optional custom activity types for the share sheet (default: `nil`).
    let applicationActivities: [UIActivity]? = nil

    // UIViewControllerRepresentable Methods

    /// Creates the `UIActivityViewController` used to present the share sheet.
    ///
    /// - Parameter context: The context object provided by SwiftUI.
    /// - Returns: A configured `UIActivityViewController` ready for presentation.
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems,
                                 applicationActivities: applicationActivities)
    }

    /// Updates the existing `UIActivityViewController` when SwiftUI state changes.
    ///
    /// - Parameters:
    ///   - vc: The existing `UIActivityViewController` instance.
    ///   - context: Provides information about the current SwiftUI environment.
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {
        // No updates needed for this static implementation.
    }
}
