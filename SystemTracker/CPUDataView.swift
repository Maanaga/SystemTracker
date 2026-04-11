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
        DashboardMetricCard(
            title: "CPU",
            subtitle: viewModel.cpuUsageCase.subtitle,
            systemImage: "cpu"
        ) {
            HStack(spacing: 24) {
                VStack(spacing: 8) {
                    ZStack {
                        MetricCircleView(progress: viewModel.cpuProgressForSystem, gradient: Gradient(colors: [.white, .gray, .black]))
                            .frame(width: 88, height: 88)
                        
                        VStack(spacing: 0) {
                            Text(viewModel.cpuUsageForSystem)
                                .font(.system(size: 18, weight: .semibold))
                        }
                    }
                    
                    Text("System")
                        .font(.system(size: 12, weight: .medium))
                }
                
                VStack(spacing: 8) {
                    ZStack {
                        MetricCircleView(progress: viewModel.cpuProgressForUser, gradient: Gradient(colors: [.white, .gray, .secondary]))
                            .frame(width: 88, height: 88)
                        
                        VStack(spacing: 0) {
                            Text(viewModel.cpuUsageForUser)
                                .font(.system(size: 18, weight: .semibold))
                        }
                    }
                    
                    Text("User")
                        .font(.system(size: 12, weight: .medium))
                }
                
                VStack(spacing: 8) {
                    ZStack {
                        MetricCircleView(progress: viewModel.cpuProgressForIdle, gradient: Gradient(colors: [.white, .gray, .secondary]))
                            .frame(width: 88, height: 88)
                        
                        VStack(spacing: 0) {
                            Text(viewModel.cpuUsageForIdle)
                                .font(.system(size: 18, weight: .semibold))
                        }
                    }
                    
                    Text("Idle")
                        .font(.system(size: 12, weight: .medium))
                }
            }
            
            DashboardMetricCard(
                title: "Memory",
                subtitle: viewModel.memoryUsageCase.subtitle,
                systemImage: "memorychip"
            ) {
                Text("Total: \(String(format: "%.2f", viewModel.totalGB)) GB")
                Text("Used: \(String(format: "%.2f", viewModel.usedMemory)) GB")
                Text("Free: \(String(format: "%.2f", viewModel.freeMemory)) GB")
                Text("Compressed: \(String(format: "%.2f", viewModel.compressedFiles)) GB")
            }
            
        }
        .padding()
    }
}
