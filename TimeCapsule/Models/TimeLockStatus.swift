import Foundation

/// Represents the dynamic lock status of a TimeCapsule based on its unlock date.
public enum TimeLockStatus: Equatable, Sendable {
    case locked(remainingTime: TimeInterval)
    case readyToOpen
    case opened(openedAt: Date)
    
    public var isLocked: Bool {
        if case .locked = self { return true }
        return false
    }
    
    public var isReadyToOpen: Bool {
        if case .readyToOpen = self { return true }
        return false
    }
    
    public var isOpened: Bool {
        if case .opened = self { return true }
        return false
    }
    
    /// Monospaced countdown breakdown tuple for jitter-free digital timer displays
    public var countdownBreakdown: (days: Int, hours: Int, minutes: Int, seconds: Int)? {
        guard case .locked(let remaining) = self else { return nil }
        let totalSeconds = max(0, Int(remaining))
        let days = totalSeconds / 86400
        let hours = (totalSeconds % 86400) / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return (days, hours, minutes, seconds)
    }
    
    /// Humanized summary label (e.g., "Opens in 14 days" or "Ready to unseal")
    public var humanizedDescription: String {
        switch self {
        case .locked(let remaining):
            let totalSeconds = max(0, Int(remaining))
            let days = totalSeconds / 86400
            let hours = (totalSeconds % 86400) / 3600
            let minutes = (totalSeconds % 3600) / 60
            
            if days > 30 {
                let months = days / 30
                return "Opens in ~\(months) \(months == 1 ? "month" : "months")"
            } else if days > 0 {
                return "Opens in \(days) \(days == 1 ? "day" : "days")"
            } else if hours > 0 {
                return "Opens in \(hours)h \(minutes)m"
            } else {
                let seconds = totalSeconds % 60
                return "Opens in \(minutes)m \(seconds)s"
            }
            
        case .readyToOpen:
            return "Ready to Unseal"
            
        case .opened(let date):
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return "Unsealed on \(formatter.string(from: date))"
        }
    }
}

