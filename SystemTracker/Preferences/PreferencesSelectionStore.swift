//
//  PreferencesSelectionStore.swift
//  SystemTracker
//
//  Created by Luka Managadze on 21/04/2026.
//


import Foundation
import Combine

final class PreferencesSelectionStore: ObservableObject {
    static let shared = PreferencesSelectionStore()

    let minMenuItems = 1
    let maxMenuItems = 3

    @Published private(set) var menuItems: [PreferenceMetric] = []

    var availableItems: [PreferenceMetric] {
        PreferenceMetric.allCases.filter { !menuItems.contains($0) }
    }

    private let userDefaultsKey = "preferences.menuItems"

    private init() {
        menuItems = loadMenuItems()
    }

    func addToMenu(_ metric: PreferenceMetric) {
        guard !menuItems.contains(metric), menuItems.count < maxMenuItems else { return }
        menuItems.append(metric)
        persistMenuItems()
    }

    func removeFromMenu(_ metric: PreferenceMetric) {
        guard menuItems.count > minMenuItems,
              let index = menuItems.firstIndex(of: metric) else { return }
        menuItems.remove(at: index)
        persistMenuItems()
    }

    private func loadMenuItems() -> [PreferenceMetric] {
        let defaults = UserDefaults.standard
        guard let rawItems = defaults.array(forKey: userDefaultsKey) as? [String] else {
            return [.cpu, .memory, .disk]
        }

        let decoded = rawItems.compactMap(PreferenceMetric.init(rawValue:))
        let unique = decoded.reduce(into: [PreferenceMetric]()) { partial, item in
            if !partial.contains(item) {
                partial.append(item)
            }
        }

        let trimmed = Array(unique.prefix(maxMenuItems))
        return trimmed.isEmpty ? [.cpu, .memory, .disk] : trimmed
    }

    private func persistMenuItems() {
        let rawItems = menuItems.map(\.rawValue)
        UserDefaults.standard.set(rawItems, forKey: userDefaultsKey)
    }
}
