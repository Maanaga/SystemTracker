//
//  ScreenTimeCardView.swift
//  SystemTracker
//
//  Created by Luka Managadze on 22/04/2026.
//


import SwiftUI

struct ScreenTimeCardView: View {
    @ObservedObject var viewModel: SystemDataViewModel

    var body: some View {
        DashboardMetricCard(
            title: "Screen Time",
            subtitle: viewModel.screenTimeCardSubtitle,
            systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90"
        ) {
            VStack(alignment: .leading, spacing: 10) {
                if viewModel.screenTimeEntries.isEmpty {
                    Text("Start using apps to build usage history.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.screenTimeEntries) { entry in
                        HStack(spacing: 12) {
                            if let appIcon = entry.icon {
                                Image(nsImage: appIcon)
                                    .resizable()
                                    .interpolation(.high)
                                    .frame(width: 18, height: 18)
                                    .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                            } else {
                                Image(systemName: "app.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.secondary)
                                    .frame(width: 18, height: 18)
                            }

                            Text(entry.appName)
                                .font(.subheadline.weight(.semibold))
                                .lineLimit(1)
                                .truncationMode(.tail)

                            Spacer(minLength: 0)

                            Text(viewModel.formattedDuration(entry.duration))
                                .font(.subheadline)
                                .monospacedDigit()
                                .foregroundStyle(.secondary)

                            if entry.isActive {
                                Text("Active")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.primary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(
                                        Capsule(style: .continuous)
                                            .fill(Color.primary.opacity(0.12))
                                    )
                            }
                        }
                    }
                }
            }
        }
    }
}
