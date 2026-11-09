import SwiftUI
import Combine

public enum CapsuleFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case ready = "Ready to Open"
    case locked = "Locked"
    case opened = "Unsealed"
    
    public var id: String { rawValue }
}

/// ViewModel powering the main "My Capsules" dashboard with real-time countdown updates.
@MainActor
public final class DashboardViewModel: ObservableObject {
    @Published public var capsules: [Capsule] = []
    @Published public var selectedFilter: CapsuleFilter = .all
    @Published public var selectedCategoryId: String? = nil
    @Published public var searchQuery: String = ""
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    
    /// Reference date updated once per second to drive non-jittering countdowns
    @Published public var referenceDate: Date = Date()
    
    private let repository: CapsuleRepositoryProtocol
    private var timerCancellable: AnyCancellable?
    
    public init(repository: CapsuleRepositoryProtocol = MockCapsuleRepository()) {
        self.repository = repository
        startTimer()
    }
    
    deinit {
        timerCancellable?.cancel()
    }
    
    private func startTimer() {
        timerCancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] newDate in
                self?.referenceDate = newDate
            }
    }
    
    public func loadCapsules(for userId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            self.capsules = try await repository.fetchCapsules(for: userId)
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    public var filteredCapsules: [Capsule] {
        capsules.filter { capsule in
            // Filter by category if selected
            if let categoryId = selectedCategoryId, capsule.categoryId != categoryId {
                return false
            }
            
            // Filter by search query
            if !searchQuery.isEmpty {
                let query = searchQuery.lowercased()
                let titleMatch = capsule.title.lowercased().contains(query)
                let messageMatch = capsule.message.lowercased().contains(query)
                if !titleMatch && !messageMatch {
                    return false
                }
            }
            
            // Filter by lock status
            let status = capsule.status(at: referenceDate)
            switch selectedFilter {
            case .all:
                return true
            case .ready:
                return status.isReadyToOpen
            case .locked:
                return status.isLocked
            case .opened:
                return status.isOpened
            }
        }
    }
    
    public var readyCount: Int {
        capsules.filter { $0.status(at: referenceDate).isReadyToOpen }.count
    }
    
    public var lockedCount: Int {
        capsules.filter { $0.status(at: referenceDate).isLocked }.count
    }
    
    public var openedCount: Int {
        capsules.filter { $0.status(at: referenceDate).isOpened }.count
    }
    
    public func deleteCapsule(_ capsule: Capsule) async {
        guard capsule.canBeDeleted(at: referenceDate) else {
            self.errorMessage = "This capsule is locked in time. The 1-hour grace window to delete has closed."
            HapticFeedback.shared.error()
            return
        }
        
        HapticFeedback.shared.warning()
        do {
            try await repository.deleteCapsule(capsuleId: capsule.id)
            NotificationManager.shared.cancelNotification(for: capsule.id)
            withAnimation(Theme.AnimationCurve.gestureSpring) {
                capsules.removeAll { $0.id == capsule.id }
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    public func updateCapsule(_ capsule: Capsule) async {
        guard capsule.canBeUpdated(at: referenceDate) else {
            self.errorMessage = "The 1-hour grace window to edit this capsule has expired."
            HapticFeedback.shared.error()
            return
        }
        
        do {
            try await repository.updateCapsule(capsule)
            await NotificationManager.shared.updateNotification(for: capsule)
            if let index = capsules.firstIndex(where: { $0.id == capsule.id }) {
                withAnimation(Theme.AnimationCurve.gestureSpring) {
                    capsules[index] = capsule
                }
            }
            HapticFeedback.shared.success()
        } catch {
            self.errorMessage = error.localizedDescription
            HapticFeedback.shared.error()
        }
    }
    
    public func markAsOpened(capsuleId: String) async {
        do {
            try await repository.markCapsuleAsOpened(capsuleId: capsuleId, openedAt: Date())
            NotificationManager.shared.cancelNotification(for: capsuleId)
            if let index = capsules.firstIndex(where: { $0.id == capsuleId }) {
                withAnimation(Theme.AnimationCurve.sealCeremony) {
                    capsules[index].isOpened = true
                    capsules[index].openedAt = Date()
                }
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}

