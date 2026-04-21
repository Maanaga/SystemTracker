//
//  PreferenceMetric.swift
//  SystemTracker
//
//  Created by Luka Managadze on 21/04/2026.
//

import Foundation

enum PreferenceMetric: String, CaseIterable, Codable, Identifiable {
    case cpu
    case memory
    case disk
    case battery

    var id: String { rawValue }

    var title: String {
        switch self {
        case .cpu: return "CPU"
        case .memory: return "Memory"
        case .disk: return "Disk"
        case .battery: return "Battery"
        }
    }

    var systemImage: String {
        switch self {
        case .cpu: return "cpu"
        case .memory: return "memorychip"
        case .disk: return "internaldrive"
        case .battery: return "battery.100"
        }
    }
}
