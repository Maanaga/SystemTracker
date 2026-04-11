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
            Label("\(viewModel.cpuUsageForSystem)", systemImage: "gearshape.fill")
            Label("\(viewModel.cpuUsageForUser)", systemImage: "person.fill")
            Label("\(viewModel.cpuUsageForIdle)", systemImage: "moon.fill")
        }
        .padding()
    }
}
