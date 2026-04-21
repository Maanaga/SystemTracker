//
//  TemperatureCardView.swift
//  SystemTracker
//
//  Created by Luka Managadze on 21/04/2026.
//

import SwiftUI
import Charts

struct TemperatureCardView: View {
    @ObservedObject var viewModel: SystemDataViewModel
    
    var body: some View {
        DashboardMetricCard(
            title: "Temperature",
            subtitle: viewModel.temperatureCardSubtitle,
            systemImage: "thermometer.medium"
        ) {
            VStack(alignment: .leading, spacing: 12) {
                if viewModel.temperatureHistory.isEmpty {
                    Text("Waiting for temperature samples…")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    Chart(viewModel.temperatureHistory) { sample in
                        LineMark(
                            x: .value("Time", sample.date),
                            y: .value("Battery Temperature", sample.celsius)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(.primary)
                        
                        AreaMark(
                            x: .value("Time", sample.date),
                            y: .value("Battery Temperature", sample.celsius)
                        )
                        .foregroundStyle(
                            .linearGradient(
                                colors: [
                                    Color.primary.opacity(0.2),
                                    Color.primary.opacity(0.05)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                    .chartXAxis {
                        AxisMarks(values: .automatic(desiredCount: 4)) { _ in
                            AxisValueLabel(format: .dateTime.hour().minute())
                        }
                    }
                    .chartYAxis {
                        AxisMarks(values: .automatic(desiredCount: 3)) { value in
                            AxisGridLine()
                            AxisValueLabel {
                                if let celsius = value.as(Double.self) {
                                    Text("\(Int(celsius.rounded()))C")
                                }
                            }
                        }
                    }
                    .frame(height: 130)
                }
            }
        }
    }
}
