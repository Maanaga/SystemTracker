//
//  SystemTrackerApp.swift
//  SystemTracker
//
//  Created by Luka Managadze on 11/04/2026.
//

import SwiftUI

@main
struct SystemTrackerApp: App {
    @StateObject private var viewModel = SystemDataViewModel()
    
    var body: some Scene {
        MenuBarExtra {
            CPUDataView(viewModel: viewModel)
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "cpu")
                Text(viewModel.cpuUsageForSystem)
                Image(systemName: "person.fill")
                Text(viewModel.cpuUsageForUser)
                Image(systemName: "moon.fill")
                Text(viewModel.cpuUsageForIdle)
            }
            .font(.caption)
            .monospacedDigit()
            .fixedSize(horizontal: true, vertical: false)
        }
        .menuBarExtraStyle(.window)
    }
}
