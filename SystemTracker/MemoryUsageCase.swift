import Foundation

enum MemoryUsageCase: Equatable, Sendable {
    case idle
    case light
    case moderate
    case high
    case critical

    static func from(usedGigabytes: Double, totalGigabytes: Double) -> MemoryUsageCase {
        guard totalGigabytes > 0 else { return .idle }
        let utilization = min(100, max(0, (usedGigabytes / totalGigabytes) * 100))
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
            return "RAM is mostly free."
        case .light:
            return "Light memory use."
        case .moderate:
            return "Moderate memory use."
        case .high:
            return "High memory use."
        case .critical:
            return "RAM is very full."
        }
    }
}
