//
//  CPUDataView.swift
//  SystemTracker
//
//  Created by Luka Managadze on 11/04/2026.
//

import SwiftUI
import Beam

struct CPUDataView: View {
    @ObservedObject var viewModel: SystemDataViewModel
    @ObservedObject private var preferencesStore = PreferencesSelectionStore.shared
    @Environment(\.dismiss) private var dismiss
    @State private var isPreferencesHovered = false
    @State private var isQuitHovered = false
    @State private var isContentVisible = false
    @State private var containerZoomScale: CGFloat = 1
    @State private var frameLift: CGFloat = 0
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            HStack(spacing: 12) {
                Button {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                        PreferencesPanelController.shared.show()
                    }
                } label: {
                    Text("Preferences")
                        .font(.headline.weight(.regular))
                        .foregroundStyle(isPreferencesHovered ? Color.primary : Color.secondary)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
                .onHover { isPreferencesHovered = $0 }
                .animation(.easeInOut(duration: 0.15), value: isPreferencesHovered)
                
                Button {
                    viewModel.quit()
                } label: {
                    Text("Quit")
                        .font(.headline.weight(.regular))
                        .foregroundStyle(isQuitHovered ? Color.primary : Color.secondary)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
                .onHover { isQuitHovered = $0 }
                .animation(.easeInOut(duration: 0.15), value: isQuitHovered)
            }
            .padding(.top, 2)
            .padding(.bottom, 2)
            .padding(.horizontal, 2)
            VStack(spacing: 12) {
                ForEach(preferencesStore.menuItems) { metric in
                    dashboardCard(for: metric)
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
        .padding(.top, 8)
        .opacity(isContentVisible ? 1 : 0)
        .offset(y: frameLift)
        .scaleEffect((isContentVisible ? 1 : 0.97) * containerZoomScale, anchor: .top)
        .blur(radius: isContentVisible ? 0 : 12)
        .saturation(isContentVisible ? 1 : 0.92)
        .compositingGroup()
        .animation(
            .spring(response: 0.46, dampingFraction: 0.9).delay(0.01),
            value: isContentVisible
        )
        .onAppear {
            isContentVisible = false
            frameLift = 10
            containerZoomScale = 0.965
            withAnimation(.spring(response: 0.36, dampingFraction: 0.88)) {
                isContentVisible = true
                frameLift = -3
                containerZoomScale = 1.035
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
                withAnimation(.easeOut(duration: 0.2)) {
                    frameLift = 0
                    containerZoomScale = 1
                }
            }
        }
        .onDisappear {
            withAnimation(.easeIn(duration: 0.14)) {
                isContentVisible = false
                frameLift = 10
                containerZoomScale = 0.965
            }
        }
        .beam(palette: .mono)
    }

    @ViewBuilder
    private func dashboardCard(for metric: PreferenceMetric) -> some View {
        switch metric {
        case .cpu:
            cpuCard
        case .memory:
            memoryCard
        case .disk:
            diskCard
        case .battery:
            batteryCard
        case .temperature:
            TemperatureCardView(viewModel: viewModel)
        case .screenTime:
            ScreenTimeCardView(viewModel: viewModel)
        }
    }
    
    private var cpuCard: some View {
        DashboardMetricCard(
            title: "CPU",
            subtitle: viewModel.cpuUsageCase.subtitle,
            systemImage: "cpu"
        ) {
            VStack(alignment: .leading, spacing: 12) {
                Text("General: \(viewModel.cpuUsageGeneral)")
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()
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
    
    private var batteryCard: some View {
        DashboardMetricCard(
            title: "Battery",
            subtitle: viewModel.batteryCardSubtitle,
            systemImage: viewModel.batterySystemImageName
        ) {
            if let snap = viewModel.batterySnapshot, snap.isBatteryPresent {
                HStack(alignment: .center, spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Battery Health: \(snap.health)%")
                                .monospacedDigit()
                            Text(snap.healthConditionText)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Text("Cycle Count: \(snap.cycleCount)")
                            .monospacedDigit()
                        
                        Text("\(snap.timeRemainingLabel)")
                            .monospacedDigit()
                        
                        HStack {
                            Text(snap.isCharging ? "Charging" : (snap.isACPowered ? "On AC power" : "On battery"))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            HStack {
                                Text("Max cap. \(snap.rawMaxCapacity ?? snap.maxCapacity ?? 0) mAh")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text("Design cap. \(snap.designCapacity ?? 0) mAh")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
    }

    private var diskCard: some View {
        DashboardMetricCard(
            title: "Disk",
            subtitle: viewModel.diskName,
            systemImage: "internaldrive"
        ) {
            HStack(alignment: .center, spacing: 20) {
                diskMemoryRow(title: "Total", value: viewModel.diskTotalGB)
                diskMemoryRow(title: "Used", value: viewModel.diskUsedGB)
                diskMemoryRow(title: "Free", value: viewModel.diskFreeGB)
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
    
    @ViewBuilder
    private func diskMemoryRow(title: String, value: Double) -> some View {
        Text("\(title): \(String(format: "%.2f", value)) GB")
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }

}
