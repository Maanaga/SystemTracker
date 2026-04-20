//
//  CPUDataView.swift
//  SystemTracker
//
//  Created by Luka Managadze on 11/04/2026.
//

import SwiftUI

struct CPUDataView: View {
    @ObservedObject var viewModel: SystemDataViewModel
    @State private var isQuitHovered = false
    @State private var isContentVisible = false
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Button {
                viewModel.quit()
            } label: {
                Text("Quit")
                    .font(.headline.weight(.regular))
                    .foregroundStyle(isQuitHovered ? Color.primary : Color.secondary)
            }
            .buttonStyle(.plain)
            .contentShape(Rectangle())
            .padding(.top, 2)
            .padding(.bottom, 2)
            .padding(.horizontal, 2)
            .onHover { isQuitHovered = $0 }
            .animation(.easeInOut(duration: 0.15), value: isQuitHovered)
            .opacity(isContentVisible ? 1 : 0)
            .offset(y: isContentVisible ? 0 : -6)
            .blur(radius: isContentVisible ? 0 : 3)
            .animation(.easeOut(duration: 0.2), value: isContentVisible)
            VStack(spacing: 12) {
                animatedAppear(cpuCard, delay: 0.02)
                animatedAppear(memoryCard, delay: 0.08)
                animatedAppear(batteryCard, delay: 0.14)
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
        .padding(.top, 8)
        .onAppear {
            isContentVisible = false
            withAnimation(.spring(response: 0.36, dampingFraction: 0.88)) {
                isContentVisible = true
            }
        }
        .onDisappear {
            isContentVisible = false
        }
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
    private func animatedAppear<V: View>(_ view: V, delay: Double) -> some View {
        view
            .opacity(isContentVisible ? 1 : 0)
            .offset(y: isContentVisible ? 0 : 10)
            .scaleEffect(isContentVisible ? 1 : 0.985, anchor: .top)
            .blur(radius: isContentVisible ? 0 : 8)
            .animation(
                .spring(response: 0.42, dampingFraction: 0.9).delay(delay),
                value: isContentVisible
            )
    }
}
