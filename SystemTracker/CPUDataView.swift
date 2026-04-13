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
        VStack(spacing: 12) {
            cpuCard
            memoryCard
        }
        .padding()
    }
    
    private var cpuCard: some View {
        DashboardMetricCard(
            title: "CPU",
            subtitle: viewModel.cpuUsageCase.subtitle,
            systemImage: "cpu"
        ) {
            HStack(spacing: 24) {
                cpuUsageCircle(
                    title: "System",
                    value: viewModel.cpuUsageForSystem,
                    progress: viewModel.cpuProgressForSystem,
                    gradient: Gradient(colors: [.white, .gray, .black])
                )
                cpuUsageCircle(
                    title: "User",
                    value: viewModel.cpuUsageForUser,
                    progress: viewModel.cpuProgressForUser,
                    gradient: Gradient(colors: [.white, .gray, .secondary])
                )
                cpuUsageCircle(
                    title: "Idle",
                    value: viewModel.cpuUsageForIdle,
                    progress: viewModel.cpuProgressForIdle,
                    gradient: Gradient(colors: [.white, .gray, .secondary])
                )
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
    
    private var memoryCard: some View {
        DashboardMetricCard(
            title: "Memory",
            subtitle: viewModel.memoryUsageCase.subtitle,
            systemImage: "memorychip"
        ) {
            HStack(alignment: .center, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    memoryRow(title: "Total", value: viewModel.totalGB)
                    memoryRow(title: "Used", value: viewModel.usedMemory)
                    memoryRow(title: "Free", value: viewModel.freeMemory)
                    memoryRow(title: "Compressed", value: viewModel.compressedFiles)
                }
                
                Spacer(minLength: 0)
                
                ZStack {
                    MetricCircleView(progress: viewModel.memoryProgress, gradient: Gradient(colors: [.white, .gray, .secondary]))
                        .frame(width: 88, height: 88)
                    Text(viewModel.memoryPercentage)
                        .font(.system(size: 18, weight: .semibold))
                        .monospacedDigit()
                }
            }
        }
    }
    
    @ViewBuilder
    private func cpuUsageCircle(
        title: String,
        value: String,
        progress: Double,
        gradient: Gradient
    ) -> some View {
        VStack(spacing: 8) {
            ZStack {
                MetricCircleView(progress: progress, gradient: gradient)
                    .frame(width: 88, height: 88)
                Text(value)
                    .font(.system(size: 18, weight: .semibold))
                    .monospacedDigit()
            }
            Text(title)
                .font(.system(size: 12, weight: .medium))
        }
    }
    
    @ViewBuilder
    private func memoryRow(title: String, value: Double) -> some View {
        Text("\(title): \(String(format: "%.2f", value)) GB")
            .monospacedDigit()
    }
}
