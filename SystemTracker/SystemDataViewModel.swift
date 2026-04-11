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
            }
    }
}
