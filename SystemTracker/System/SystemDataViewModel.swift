//
//  SystemDataViewModel.swift
//  SystemTracker
//
//  Created by Luka Managadze on 11/04/2026.
//

import SwiftUI
import Combine
import SystemKit
import IOKit

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
    @Published private(set) var temperatureCurrent: String = "--"
    @Published private(set) var temperatureMin: String = "--"
    @Published private(set) var temperatureMax: String = "--"
    @Published private(set) var temperatureCardSubtitle: String = "Waiting for sensor data…"
    @Published private(set) var temperatureHistory: [TemperatureSample] = []
    
    let totalGB = System.physicalMemory(.gigabyte)
    
    var batterySystemImageName: String {
        batterySnapshot?.systemImageName ?? "battery.0percent"
    }
    
    
    private var system = System()
    private var systemKitBattery = Battery()
    private var timer: AnyCancellable?
    private var isTemperatureSensorAvailable = false
    private let temperatureHistoryLimit = 120
    
    init() {
        setupTemperatureSensor()
        startMonitoring()
    }

    deinit {
        if isTemperatureSensorAvailable {
            _ = systemKitBattery.close()
        }
    }
    
    func startMonitoring() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                updateCPU()
                updateMemory()
                updateDisk()
                updateBattery()
                updateTemperature()
            }
    }
    
    //MARK: - CPU
    private func updateCPU() {
        let usage = self.system.usageCPU()
        let generalUsage = min(100, max(0, usage.system + usage.user))
        cpuUsageGeneral = String(format: "%.1f%%", generalUsage)
        cpuUsageForSystem = String(format: "%.1f%%", usage.system)
        cpuUsageForUser = String(format: "%.1f%%", usage.user)
        cpuUsageForIdle = String(format: "%.1f%%", usage.idle)
        cpuProgressGeneral = generalUsage / 100.0
        cpuProgressForSystem = usage.system / 100.0
        cpuProgressForUser = usage.user / 100.0
        cpuProgressForIdle = usage.idle / 100.0
        cpuUsageCase = CPUUsageCase.from(
            systemPercent: usage.system,
            userPercent: usage.user
        )
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

    //MARK: - Temperature
    private func updateTemperature() {
        guard isTemperatureSensorAvailable else {
            temperatureCardSubtitle = "Temperature sensor is unavailable on this Mac"
            temperatureCurrent = "--"
            temperatureMin = "--"
            temperatureMax = "--"
            return
        }

        let batteryTemperature = systemKitBattery.temperature(.celsius)
        guard batteryTemperature.isFinite, batteryTemperature > 0 else {
            temperatureCardSubtitle = "No battery temperature data from SystemKit"
            return
        }

        let now = Date()
        temperatureHistory.append(TemperatureSample(date: now, celsius: batteryTemperature))
        if temperatureHistory.count > temperatureHistoryLimit {
            temperatureHistory.removeFirst(temperatureHistory.count - temperatureHistoryLimit)
        }

        temperatureCurrent = formattedTemperature(batteryTemperature)

        if let minSample = temperatureHistory.min(by: { $0.celsius < $1.celsius }) {
            temperatureMin = formattedTemperature(minSample.celsius)
        }

        if let maxSample = temperatureHistory.max(by: { $0.celsius < $1.celsius }) {
            temperatureMax = formattedTemperature(maxSample.celsius)
        }

        temperatureCardSubtitle = "SystemKit battery thermal history"
    }
    
    func quit() {
        NSApplication.shared.terminate(self)
    }
    
    private func bytesToGigabytes(_ bytes: Int64) -> Double {
        Double(bytes) / 1_073_741_824.0
    }

    private func formattedTemperature(_ celsius: Double) -> String {
        String(format: "%.2fC", celsius)
    }

    private func setupTemperatureSensor() {
        let result = systemKitBattery.open()
        isTemperatureSensorAvailable = (result == KERN_SUCCESS || result == SystemKit.kIOReturnStillOpen)
        if !isTemperatureSensorAvailable {
            temperatureCardSubtitle = "Temperature sensor is unavailable on this Mac"
        }
    }
}

struct TemperatureSample: Identifiable {
    let id = UUID()
    let date: Date
    let celsius: Double
}
