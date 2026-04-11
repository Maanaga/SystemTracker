//
//  CPUDataView.swift
//  SystemTracker
//
//  Created by Luka Managadze on 11/04/2026.
//

import SwiftUI

struct CPUDataView: View {
    @StateObject var viewModel: SystemDataViewModel
    
    var body: some View {
        VStack {
            Text(viewModel.cpuUsage)
        }
    }
}
