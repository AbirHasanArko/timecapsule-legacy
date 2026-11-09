import Foundation

/// Core Capsule domain model. A sealed container holding a message, photo, and future date.
public struct Capsule: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public let userId: String
    public var title: String
    public var message: String
    public var photoURL: URL?
    public var localImageData: Data?
    public var categoryId: String
    public let createdAt: Date
    public var unlockDate: Date
    public var isOpened: Bool
    public var openedAt: Date?
    public var sealType: SealType
    
    /// Default grace period (1 hour) during which updates or cancellations are allowed
    public static let defaultGracePeriodDuration: TimeInterval = 3600 // 60 minutes
    
    public init(
        id: String = UUID().uuidString,
        userId: String,
        title: String,
        message: String,
        photoURL: URL? = nil,
        localImageData: Data? = nil,
        categoryId: String,
        createdAt: Date = Date(),
        unlockDate: Date,
        isOpened: Bool = false,
        openedAt: Date? = nil,
        sealType: SealType = .waxSeal
    ) {
        self.id = id
        self.userId = userId
        self.title = title
        self.message = message
        self.photoURL = photoURL
        self.localImageData = localImageData
        self.categoryId = categoryId
        self.createdAt = createdAt
        self.unlockDate = unlockDate
        self.isOpened = isOpened
        self.openedAt = openedAt
        self.sealType = sealType
    }
    
    /// Computes dynamic status at any reference timestamp
    public func status(at referenceDate: Date = Date()) -> TimeLockStatus {
        if isOpened {
            return .opened(openedAt: openedAt ?? unlockDate)
        }
        
        let remaining = unlockDate.timeIntervalSince(referenceDate)
        if remaining <= 0 {
            return .readyToOpen
        } else {
            return .locked(remainingTime: remaining)
        }
    }
    
    // MARK: - CRUD Rules & Timed Grace Window
    
    /// Checks if the capsule is still inside the timed modification/deletion window (e.g. 1 hour after sealing)
    public func isWithinGraceWindow(
        at referenceDate: Date = Date(),
        window: TimeInterval = defaultGracePeriodDuration
    ) -> Bool {
        guard !isOpened else { return false }
        let elapsed = referenceDate.timeIntervalSince(createdAt)
        return elapsed >= 0 && elapsed <= window
    }
    
    /// Returns the remaining seconds before the edit/cancellation grace window permanently closes
    public func remainingGraceTime(
        at referenceDate: Date = Date(),
        window: TimeInterval = defaultGracePeriodDuration
    ) -> TimeInterval? {
        guard isWithinGraceWindow(at: referenceDate, window: window) else { return nil }
        let elapsed = referenceDate.timeIntervalSince(createdAt)
        return max(0, window - elapsed)
    }
    
    /// Formatted countdown label for the grace window (e.g. "48m 12s remaining to edit")
    public func formattedRemainingGraceTime(
        at referenceDate: Date = Date(),
        window: TimeInterval = defaultGracePeriodDuration
    ) -> String? {
        guard let remaining = remainingGraceTime(at: referenceDate, window: window) else { return nil }
        let total = Int(remaining)
        let mins = total / 60
        let secs = total % 60
        return String(format: "%02dm %02ds", mins, secs)
    }
    
    /// Updates are strictly permitted only during the timed grace window
    public func canBeUpdated(at referenceDate: Date = Date()) -> Bool {
        isWithinGraceWindow(at: referenceDate)
    }
    
    /// Deletion is permitted during the grace window OR after the capsule has been opened/archived
    public func canBeDeleted(at referenceDate: Date = Date()) -> Bool {
        isWithinGraceWindow(at: referenceDate) || isOpened
    }
    
    /// Reading full message and photos is strictly locked until unsealed
    public func canReadContent(at referenceDate: Date = Date()) -> Bool {
        isOpened
    }
}

// MARK: - Seal Type
public enum SealType: String, Codable, Sendable, CaseIterable, Identifiable {
    case waxSeal = "wax_seal"
    case chronolock = "chrono_lock"
    case envelope = "envelope"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .waxSeal: return "Crimson Wax Seal"
        case .chronolock: return "Chrono Vault"
        case .envelope: return "Parchment Fold"
        }
    }
    
    public var iconName: String {
        switch self {
        case .waxSeal: return "seal.fill"
        case .chronolock: return "lock.circle.fill"
        case .envelope: return "envelope.fill"
        }
    }
}

