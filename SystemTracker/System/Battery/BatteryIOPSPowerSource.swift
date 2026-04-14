//
//  BatteryIOPSPowerSource.swift
//  SystemTracker
//
//  Created by Luka Managadze on 13/04/2026.
//

import Foundation
import IOKit
import IOKit.ps

enum BatteryIOPSPowerSource {
    static func fetchPrimaryBatteryDictionary() throws -> [String: Any] {
        guard let blob = IOPSCopyPowerSourcesInfo()?.takeRetainedValue() else {
            throw BatteryIOPSError.noPowerSources
        }

        guard let list = IOPSCopyPowerSourcesList(blob)?.takeRetainedValue() else {
            throw BatteryIOPSError.noPowerSources
        }

        let sources = list as NSArray
        guard sources.count > 0 else {
            throw BatteryIOPSError.noPowerSources
        }

        for i in 0..<sources.count {
            let ps = sources[i] as CFTypeRef
            guard let description = IOPSGetPowerSourceDescription(blob, ps)?.takeUnretainedValue() else { continue }
            let nsDict = description as NSDictionary
            guard let dict = nsDict as? [String: Any] else { continue }

            if dict[kIOPSTypeKey] as? String == kIOPSInternalBatteryType {
                var merged = dict
                if let registry = fetchSmartBatteryRegistryProperties() {
                    for (key, value) in registry {
                        merged[key] = value
                    }
                }
                return merged
            }
        }

        throw BatteryIOPSError.noPowerSources
    }

    private static func fetchSmartBatteryRegistryProperties() -> [String: Any]? {
        let matching = IOServiceMatching("AppleSmartBattery")
        let service = IOServiceGetMatchingService(kIOMainPortDefault, matching)
        guard service != 0 else { return nil }
        defer { IOObjectRelease(service) }

        var properties: Unmanaged<CFMutableDictionary>?
        let result = IORegistryEntryCreateCFProperties(
            service,
            &properties,
            kCFAllocatorDefault,
            0
        )
        guard result == KERN_SUCCESS, let properties else { return nil }

        let ns = properties.takeRetainedValue() as NSDictionary
        return ns as? [String: Any]
    }
}
