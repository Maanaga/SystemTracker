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
    @Published var cpuUsage: String = ""
    
    private var system = System()
    private var timer: AnyCancellable?
    
    init() {
        startMonitoring()
    }
    
    func startMonitoring() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.cpuUsage = self?.cpuUsageString() ?? ""
            }
    }
    
    private func cpuUsageString() -> String {
        let usage = system.usageCPU()
        return String(format: "system: %.1f%%  user: %.1f%%  idle: %.1f%% ", usage.system, usage.user, usage.idle)
    }
}
