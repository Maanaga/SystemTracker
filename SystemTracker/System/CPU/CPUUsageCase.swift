import Foundation

enum CPUUsageCase: Equatable, Sendable {
    case idle
    case light
    case moderate
    case high
    case critical

    static func from(systemPercent: Double, userPercent: Double) -> CPUUsageCase {
        let utilization = min(100, max(0, systemPercent + userPercent))
        switch utilization {
        case ..<10: return .idle
        case ..<35: return .light
        case ..<65: return .moderate
        case ..<90: return .high
        default: return .critical
        }
    }

    var subtitle: String {
        switch self {
        case .idle:
            return "CPU is nearly idle."
        case .light:
            return "Light load - plenty of headroom."
        case .moderate:
            return "Moderate usage - typical for everyday work."
        case .high:
            return "High load - apps are working the CPU hard."
        case .critical:
            return "Very high load - system may feel sluggish."
        }
    }
}
