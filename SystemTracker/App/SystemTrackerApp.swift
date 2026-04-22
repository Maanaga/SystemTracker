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
            Image(systemName: "gauge.with.needle")
                .font(.caption)
                .monospacedDigit()
                .fixedSize(horizontal: true, vertical: false)
        }
        .menuBarExtraStyle(.window)
    }
}
