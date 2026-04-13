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
    @Published var cpuUsageForSystem: String = ""
    @Published var cpuUsageForUser: String = ""
    @Published var cpuUsageForIdle: String = ""
    
    @Published var cpuProgressForSystem: Double = 0.0
    @Published var cpuProgressForUser: Double = 0.0
    @Published var cpuProgressForIdle: Double = 0.0
    
    @Published var cpuUsageCase: CPUUsageCase = .idle
    @Published var memoryUsageCase: MemoryUsageCase = .idle
    
    @Published var usedMemory: Double = 0.0
    @Published var freeMemory: Double = 0.0
    @Published var cachedFiles: Double = 0.0
    @Published var compressedFiles: Double = 0.0
    @Published var memoryProgress: Double = 0.0
    @Published var memoryPercentage: String = ""
    
    let totalGB = System.physicalMemory(.gigabyte)
    
    
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
                self.cpuUsageForSystem = String(format: "%.1f%%", usage.system)
                self.cpuUsageForUser = String(format: "%.1f%%", usage.user)
                self.cpuUsageForIdle = String(format: "%.1f%%", usage.idle)
                self.cpuProgressForSystem = usage.system / 100.0
                self.cpuProgressForUser = usage.user / 100.0
                self.cpuProgressForIdle = usage.idle / 100.0
                self.cpuUsageCase = CPUUsageCase.from(
                    systemPercent: usage.system,
                    userPercent: usage.user
                )
                updateMemory()
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
    
    func quit() {
        NSApplication.shared.terminate(self)
    }
}
