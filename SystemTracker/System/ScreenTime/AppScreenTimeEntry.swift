//
//  AppScreenTimeEntry.swift
//  SystemTracker
//
//  Created by Luka Managadze on 22/04/2026.
//
import Foundation
import AppKit

struct AppScreenTimeEntry: Identifiable {
    let id = UUID()
    let bundleIdentifier: String
    let appName: String
    let duration: TimeInterval
    let icon: NSImage?
    let isActive: Bool
}
