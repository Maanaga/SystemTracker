//
//  PreferencesView.swift
//  SystemTracker
//
//  Created by Luka Managadze on 21/04/2026.
//


import SwiftUI

struct PreferencesView: View {
    @ObservedObject private var preferencesStore = PreferencesSelectionStore.shared

    var body: some View {
        HStack(alignment: .top, spacing: 18) {
            selectionColumn(
                title: "Menu view",
                subtitle: "\(preferencesStore.minMenuItems)-\(preferencesStore.maxMenuItems) items",
                items: preferencesStore.menuItems,
                mode: .selected
            )

            selectionColumn(
                title: "Available",
                subtitle: "click to append",
                items: preferencesStore.availableItems,
                mode: .available
            )
        }
        .padding(18)
        .frame(width: 500, height: 360, alignment: .top)
        .glassEffect(in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    @ViewBuilder
    private func selectionColumn(
        title: String,
        subtitle: String,
        items: [PreferenceMetric],
        mode: SelectionColumnMode
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primary)

                Text(subtitle)
                    .font(.headline.weight(.regular))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 2)

            VStack(spacing: 8) {
                ForEach(items) { item in
                    HStack(spacing: 12) {
                        Image(systemName: item.systemImage)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.primary)
                            .frame(width: 24, alignment: .center)

                        Text(item.title)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)

                        Spacer(minLength: 8)

                        if mode == .selected {
                            Button {
                                preferencesStore.removeFromMenu(item)
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(
                                        preferencesStore.menuItems.count > preferencesStore.minMenuItems
                                        ? .secondary
                                        : .tertiary
                                    )
                                    .frame(width: 24, height: 24)
                            }
                            .buttonStyle(.plain)
                            .disabled(preferencesStore.menuItems.count <= preferencesStore.minMenuItems)
                        } else {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(preferencesStore.menuItems.count < preferencesStore.maxMenuItems ? .secondary : .tertiary)
                                .frame(width: 24, height: 24)
                        }
                    }
                    .padding(.horizontal, 14)
                    .frame(height: 52)
                    .background {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.black.opacity(0.22))
                    }
                    .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .onTapGesture {
                        if mode == .available {
                            preferencesStore.addToMenu(item)
                        }
                    }
                }
            }
            .padding(12)
            .background {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.clear)
                    .strokeBorder(Color.white.opacity(0.24), lineWidth: 1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

private enum SelectionColumnMode {
    case selected
    case available
}

#Preview {
    PreferencesView()
}
