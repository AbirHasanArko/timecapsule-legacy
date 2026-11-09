import SwiftUI
import PhotosUI

public enum UnlockDatePreset: String, CaseIterable, Identifiable {
    case oneMonth = "1 Month"
    case sixMonths = "6 Months"
    case oneYear = "1 Year"
    case fiveYears = "5 Years"
    case custom = "Custom"
    
    public var id: String { rawValue }
    
    public func targetDate(from now: Date = Date()) -> Date {
        let calendar = Calendar.current
        switch self {
        case .oneMonth:
            return calendar.date(byAdding: .month, value: 1, to: now) ?? now
        case .sixMonths:
            return calendar.date(byAdding: .month, value: 6, to: now) ?? now
        case .oneYear:
            return calendar.date(byAdding: .year, value: 1, to: now) ?? now
        case .fiveYears:
            return calendar.date(byAdding: .year, value: 5, to: now) ?? now
        case .custom:
            return calendar.date(byAdding: .day, value: 7, to: now) ?? now
        }
    }
}

/// ViewModel powering the capsule creation studio and Future Self letter writer.
@MainActor
public final class CreateCapsuleViewModel: ObservableObject {
    @Published public var title: String = ""
    @Published public var message: String = ""
    @Published public var selectedCategoryId: String = "future_self"
    @Published public var selectedPreset: UnlockDatePreset = .sixMonths
    @Published public var customDate: Date = Calendar.current.date(byAdding: .month, value: 6, to: Date()) ?? Date()
    @Published public var selectedSealType: SealType = .waxSeal
    
    // Photo Attachment
    @Published public var selectedPhotoItem: PhotosPickerItem? = nil
    @Published public var attachedImageData: Data? = nil
    
    // Sealing Animation Progress
    @Published public var sealingProgress: Double = 0.0
    @Published public var isSealing: Bool = false
    @Published public var isSavedSuccessfully: Bool = false
    @Published public var errorMessage: String? = nil
    
    public let categories: [CapsuleCategory]
    public let prompts: [InspirationalPrompt]
    private let repository: CapsuleRepositoryProtocol
    
    public init(
        repository: CapsuleRepositoryProtocol = MockCapsuleRepository(),
        promptService: PromptService = PromptService.shared
    ) {
        self.repository = repository
        self.categories = promptService.loadCategories()
        self.prompts = promptService.loadPrompts()
    }
    
    public var calculatedUnlockDate: Date {
        if selectedPreset == .custom {
            return customDate
        } else {
            return selectedPreset.targetDate()
        }
    }
    
    public var canSeal: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !message.trimmingCharacters(in: .whitespaces).isEmpty &&
        calculatedUnlockDate > Date()
    }
    
    public func applyPrompt(_ prompt: InspirationalPrompt) {
        HapticFeedback.shared.selectionChanged()
        if message.isEmpty {
            message = prompt.text + "\n\n"
        } else {
            message += "\n\n" + prompt.text + "\n\n"
        }
    }
    
    public func handlePhotoSelection(_ item: PhotosPickerItem?) async {
        guard let item = item else { return }
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                self.attachedImageData = data
                HapticFeedback.shared.light()
            }
        } catch {
            self.errorMessage = "Failed to load selected photo."
        }
    }
    
    public func removeAttachedPhoto() {
        withAnimation(Theme.AnimationCurve.gestureSpring) {
            self.attachedImageData = nil
            self.selectedPhotoItem = nil
        }
        HapticFeedback.shared.light()
    }
    
    public func sealCapsule(userId: String) async -> Bool {
        guard canSeal else {
            errorMessage = "Please provide both a title, a message, and a future opening date."
            HapticFeedback.shared.error()
            return false
        }
        
        isSealing = true
        HapticFeedback.shared.latchEngaged()
        
        // Progress animation for physical feel
        for i in 1...10 {
            try? await Task.sleep(nanoseconds: 50_000_000)
            self.sealingProgress = Double(i) / 10.0
            if i % 3 == 0 {
                HapticFeedback.shared.tick()
            }
        }
        
        let newCapsule = Capsule(
            userId: userId,
            title: title.trimmingCharacters(in: .whitespaces),
            message: message.trimmingCharacters(in: .whitespaces),
            photoURL: nil,
            localImageData: attachedImageData,
            categoryId: selectedCategoryId,
            createdAt: Date(),
            unlockDate: calculatedUnlockDate,
            isOpened: false,
            sealType: selectedSealType
        )
        
        do {
            try await repository.saveCapsule(newCapsule)
            await NotificationManager.shared.scheduleNotification(for: newCapsule)
            HapticFeedback.shared.success()
            isSavedSuccessfully = true
            isSealing = false
            return true
        } catch {
            self.errorMessage = error.localizedDescription
            isSealing = false
            HapticFeedback.shared.error()
            return false
        }
    }
}

