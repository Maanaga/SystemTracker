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
        HStack(spacing: 24) {
            ZStack {
                MetricCircleView(progress: viewModel.cpuProgressForSystem, gradient: Gradient(colors: [.white, .gray, .black]))
                    .frame(width: 88, height: 88)
                
                VStack(spacing: 0) {
                    Text(viewModel.cpuUsageForSystem)
                        .font(.system(size: 18, weight: .semibold))
                }
            }
            
            ZStack {
                MetricCircleView(progress: viewModel.cpuProgressForUser, gradient: Gradient(colors: [.white, .gray, .secondary]))
                    .frame(width: 88, height: 88)
                
                VStack(spacing: 0) {
                    Text(viewModel.cpuUsageForUser)
                        .font(.system(size: 18, weight: .semibold))
                }
            }
            
            ZStack {
                MetricCircleView(progress: viewModel.cpuProgressForIdle, gradient: Gradient(colors: [.white, .gray, .secondary]))
                    .frame(width: 88, height: 88)
                
                VStack(spacing: 0) {
                    Text(viewModel.cpuUsageForIdle)
                        .font(.system(size: 18, weight: .semibold))
                }
            }
            
        }
        .padding()
    }
}
