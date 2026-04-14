//
//  BatterySnapshot.swift
//  SystemTracker
//
//  Created by Luka Managadze on 13/04/2026.
//

import Foundation
import IOKit.ps

struct BatterySnapshot: Sendable {
    var isACPowered: Bool
    var isCharging: Bool
    var isBatteryPresent: Bool
    var currentCapacity: Int?
    var designCapacity: Int?
    var maxCapacity: Int
    var cycleCount: Int
    var health: Int
}

extension BatterySnapshot {

    private static let cycleCountKey = "CycleCount"
    private static let rawCurrentCapacityKey = "AppleRawCurrentCapacity"
    private static let rawMaxCapacityKey = "AppleRawMaxCapacity"
    private static let batteryHealthTextKey = "BatteryHealth"

    init(powerSourceDictionary dict: [String: Any]) {
        let state = dict[kIOPSPowerSourceStateKey] as? String
        isACPowered = state == kIOPSACPowerValue
        isCharging = Self.bool(dict[kIOPSIsChargingKey])
        isBatteryPresent = Self.bool(dict[kIOPSIsPresentKey], defaultIfMissing: true)

        let rawCurrentCapacity = Self.int(dict[Self.rawCurrentCapacityKey])
        let rawMaxCapacity = Self.int(dict[Self.rawMaxCapacityKey])
        let percentCurrentCapacity = Self.int(dict[kIOPSCurrentCapacityKey])

        if let percentCurrentCapacity {
            currentCapacity = percentCurrentCapacity
        } else if let rawCurrentCapacity, let rawMaxCapacity, rawMaxCapacity > 0 {
            currentCapacity = min(100, max(0, rawCurrentCapacity * 100 / rawMaxCapacity))
        } else {
            currentCapacity = nil
        }

        designCapacity = Self.int(dict[kIOPSDesignCapacityKey]) ?? Self.int(dict["DesignCapacity"])
        maxCapacity = Self.int(dict[kIOPSMaxCapacityKey]) ?? 100

        cycleCount = Self.int(dict[Self.cycleCountKey]) ?? 0

        if let rawMaxCapacity, let design = designCapacity, design > 0 {
            health = min(100, max(0, rawMaxCapacity * 100 / design))
        } else if let healthText = dict[Self.batteryHealthTextKey] as? String {
            switch healthText {
            case "Good":
                health = 100
            case "Fair":
                health = 80
            case "Poor":
                health = 60
            default:
                health = 100
            }
        } else {
            health = 100
        }
    }

    var chargePercentForDisplay: Int? {
        guard let current = currentCapacity, maxCapacity > 0 else { return nil }
        return min(100, max(0, current * 100 / maxCapacity))
    }

    var chargeFraction: Double {
        guard let p = chargePercentForDisplay else { return 0 }
        return Double(p) / 100.0
    }

    var cardSubtitle: String {
        if !isBatteryPresent {
            return "No battery is present or the battery is not reporting data."
        }
        var parts: [String] = []
        if let p = chargePercentForDisplay {
            parts.append("\(p)%")
        }
        if isCharging {
            parts.append("charging from AC power")
        } else if isACPowered {
            parts.append("on AC power")
        } else {
            parts.append("running on battery")
        }
        return parts.joined(separator: " - ") + "."
    }

    var menuBarPercentLabel: String {
        guard isBatteryPresent else { return "—" }
        if let p = chargePercentForDisplay {
            return "\(p)%"
        }
        return "—"
    }

    var systemImageName: String {
        guard isBatteryPresent else { return "battery.0percent" }
        if isCharging {
            return "battery.100percent.bolt"
        }
        let bucket: Int = {
            guard let p = chargePercentForDisplay else { return 0 }
            switch p {
            case 85...: return 100
            case 60..<85: return 75
            case 35..<60: return 50
            case 10..<35: return 25
            default: return 0
            }
        }()
        return "battery.\(bucket)percent"
    }

    private static func int(_ value: Any?) -> Int? {
        guard let value else { return nil }
        if let v = value as? Int { return v }
        if let v = value as? Int32 { return Int(v) }
        if let v = value as? Int64 { return Int(v) }
        if let v = value as? NSNumber { return v.intValue }
        return nil
    }

    private static func bool(_ value: Any?, defaultIfMissing: Bool = false) -> Bool {
        guard let value else { return defaultIfMissing }
        if let v = value as? Bool { return v }
        if let v = value as? NSNumber { return v.boolValue }
        return defaultIfMissing
    }
}
