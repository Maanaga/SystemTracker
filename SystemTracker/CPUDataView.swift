//
//  CPUDataView.swift
//  SystemTracker
//
//  Created by Luka Managadze on 11/04/2026.
//

import SwiftUI

struct CPUDataView: View {
    @ObservedObject var viewModel: SystemDataViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                MetricCircleView(progress: viewModel.cpuProgressForSystem, gradient: Gradient(colors: [.cyan, .blue, .purple]))
                    .frame(width: 88, height: 88)
                
                VStack(spacing: 0) {
                    Text(viewModel.cpuUsageForSystem)
                        .font(.system(size: 18, weight: .semibold))
                }
            }
            
            Label("\(viewModel.cpuUsageForUser)", systemImage: "person.fill")
            Label("\(viewModel.cpuUsageForIdle)", systemImage: "moon.fill")
        }
        .padding()
    }
}
