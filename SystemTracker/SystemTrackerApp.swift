//
//  SystemTrackerApp.swift
//  SystemTracker
//
//  Created by Luka Managadze on 11/04/2026.
//

import SwiftUI

@main
struct SystemTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            CPUDataView(viewModel: SystemDataViewModel())
        }
    }
}
