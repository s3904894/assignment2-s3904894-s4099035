//
//  ShareSheet.swift
//  Habood
//
//  Created by yunlong chen on 2025/10/15.
//
import SwiftUI
import UIKit

/// A SwiftUI wrapper for UIKit's UIActivityViewController.
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems,
                                 applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}
