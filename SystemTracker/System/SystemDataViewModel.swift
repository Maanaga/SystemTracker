//
//  SystemDataViewModel.swift
//  SystemTracker
//
//  Created by Luka Managadze on 11/04/2026.
//

import SwiftUI
import Combine
import SystemKit

final class SystemDataViewModel: ObservableObject {
    @Published var cpuUsageGeneral: String = ""
    @Published var cpuUsageForSystem: String = ""
    @Published var cpuUsageForUser: String = ""
    @Published var cpuUsageForIdle: String = ""
    
    @Published var cpuProgressForSystem: Double = 0.0
    @Published var cpuProgressForUser: Double = 0.0
    @Published var cpuProgressForIdle: Double = 0.0
    @Published var cpuProgressGeneral: Double = 0.0
    
    @Published var cpuUsageCase: CPUUsageCase = .idle
    @Published var memoryUsageCase: MemoryUsageCase = .idle
    
    @Published var usedMemory: Double = 0.0
    @Published var freeMemory: Double = 0.0
    @Published var cachedFiles: Double = 0.0
    @Published var compressedFiles: Double = 0.0
    @Published var memoryProgress: Double = 0.0
    @Published var memoryPercentage: String = ""

    @Published var diskName: String = "Loading..."
    @Published var diskUsedGB: Double = 0.0
    @Published var diskFreeGB: Double = 0.0
    @Published var diskTotalGB: Double = 0.0
    
    @Published private(set) var batterySnapshot: BatterySnapshot?
    @Published private(set) var batteryCardSubtitle: String = "Loading battery information…"
    
    let totalGB = System.physicalMemory(.gigabyte)
    
    var batterySystemImageName: String {
        batterySnapshot?.systemImageName ?? "battery.0percent"
    }
    
    
    private var system = System()
    private var timer: AnyCancellable?
    
    init() {
        startMonitoring()
    }
    
    func startMonitoring() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                let usage = self.system.usageCPU()
                let generalUsage = min(100, max(0, usage.system + usage.user))
                self.cpuUsageGeneral = String(format: "%.1f%%", generalUsage)
                self.cpuUsageForSystem = String(format: "%.1f%%", usage.system)
                self.cpuUsageForUser = String(format: "%.1f%%", usage.user)
                self.cpuUsageForIdle = String(format: "%.1f%%", usage.idle)
                self.cpuProgressGeneral = generalUsage / 100.0
                self.cpuProgressForSystem = usage.system / 100.0
                self.cpuProgressForUser = usage.user / 100.0
                self.cpuProgressForIdle = usage.idle / 100.0
                self.cpuUsageCase = CPUUsageCase.from(
                    systemPercent: usage.system,
                    userPercent: usage.user
                )
                updateMemory()
                updateDisk()
                updateBattery()
            }
    }
    
    //MARK: - Memory
    private func updateMemory() {
        let memory = System.memoryUsage()
        freeMemory = memory.free
        cachedFiles = memory.cachedFiles
        compressedFiles = memory.compressed
        usedMemory = max(0, totalGB - memory.free)
        memoryProgress = min(1, max(0, usedMemory / totalGB))
        memoryUsageCase = MemoryUsageCase.from(
            usedGigabytes: usedMemory,
            totalGigabytes: totalGB
        )
        memoryPercentage = String(format: "%.1f%%", memoryProgress * 100)
    }

    //MARK: - Disk
    private func updateDisk() {
        let rootURL = URL(fileURLWithPath: "/")
        let keys: Set<URLResourceKey> = [
            .volumeNameKey,
            .volumeLocalizedNameKey,
            .volumeTotalCapacityKey,
            .volumeAvailableCapacityForImportantUsageKey,
            .volumeAvailableCapacityKey
        ]

        do {
            let values = try rootURL.resourceValues(forKeys: keys)
            let totalBytes = Int64(values.volumeTotalCapacity ?? 0)
            let importantFreeBytes = values.volumeAvailableCapacityForImportantUsage
            let fallbackFreeBytes = values.volumeAvailableCapacity.map(Int64.init)
            let freeBytes = importantFreeBytes ?? fallbackFreeBytes ?? Int64(0)

            guard totalBytes > 0 else {
                diskName = values.volumeLocalizedName ?? values.volumeName ?? "System Disk"
                diskUsedGB = 0
                diskFreeGB = 0
                diskTotalGB = 0
                return
            }

            let usedBytes = max(Int64(0), totalBytes - freeBytes)
            _ = min(1.0, max(0.0, Double(usedBytes) / Double(totalBytes)))

            diskName = values.volumeLocalizedName ?? values.volumeName ?? "System Disk"
            diskUsedGB = bytesToGigabytes(usedBytes)
            diskFreeGB = bytesToGigabytes(freeBytes)
            diskTotalGB = bytesToGigabytes(totalBytes)
        } catch {
            diskName = "System Disk"
            diskUsedGB = 0
            diskFreeGB = 0
            diskTotalGB = 0
        }
    }
    
    //MARK: - Battery
    private func updateBattery() {
        do {
            let dict = try BatteryIOPSPowerSource.fetchPrimaryBatteryDictionary()
            let snapshot = BatterySnapshot(powerSourceDictionary: dict)
            batterySnapshot = snapshot
            batteryCardSubtitle = snapshot.cardSubtitle
        } catch {
            batterySnapshot = nil
            batteryCardSubtitle =
                "No internal battery was found"
        }
    }
    
    func quit() {
        NSApplication.shared.terminate(self)
    }

    private func bytesToGigabytes(_ bytes: Int64) -> Double {
        Double(bytes) / 1_073_741_824.0
    }
}
