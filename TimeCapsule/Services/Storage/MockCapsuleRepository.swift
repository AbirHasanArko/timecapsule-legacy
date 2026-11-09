import Foundation

/// Thread-safe in-memory mock repository for local previews, tests, and demo mode.
public actor MockCapsuleRepository: CapsuleRepositoryProtocol {
    private var capsules: [Capsule] = []
    
    public init(preloaded: Bool = true) {
        if preloaded {
            self.capsules = MockCapsuleRepository.sampleData()
        }
    }
    
    public func fetchCapsules(for userId: String) async throws -> [Capsule] {
        return capsules.filter { $0.userId == userId || $0.userId == "demo_user" }
    }
    
    public func saveCapsule(_ capsule: Capsule) async throws {
        if let index = capsules.firstIndex(where: { $0.id == capsule.id }) {
            capsules[index] = capsule
        } else {
            capsules.insert(capsule, at: 0)
        }
    }
    
    public func updateCapsule(_ capsule: Capsule) async throws {
        guard let index = capsules.firstIndex(where: { $0.id == capsule.id }) else {
            throw NSError(domain: "TimeCapsule", code: 404, userInfo: [NSLocalizedDescriptionKey: "Capsule not found"])
        }
        guard capsule.canBeUpdated() else {
            throw NSError(domain: "TimeCapsule", code: 403, userInfo: [NSLocalizedDescriptionKey: "Modification window expired. Capsule is locked in time."])
        }
        capsules[index] = capsule
    }
    
    public func markCapsuleAsOpened(capsuleId: String, openedAt: Date = Date()) async throws {
        guard let index = capsules.firstIndex(where: { $0.id == capsuleId }) else {
            throw NSError(domain: "TimeCapsule", code: 404, userInfo: [NSLocalizedDescriptionKey: "Capsule not found"])
        }
        capsules[index].isOpened = true
        capsules[index].openedAt = openedAt
    }
    
    public func deleteCapsule(capsuleId: String) async throws {
        capsules.removeAll { $0.id == capsuleId }
    }
    
    // MARK: - Sample Data
    public static func sampleData() -> [Capsule] {
        let now = Date()
        
        return [
            // 1. Newly Sealed Capsule with Active 1-Hour Grace Window (Opens in 30 days)
            Capsule(
                id: "sample_grace_1",
                userId: "demo_user",
                title: "Thoughts Sealed 15 Minutes Ago",
                message: "This capsule was just created 15 minutes ago. You have 45 minutes remaining in your grace window to edit the contents or cancel/delete it. Once this window closes, it is permanently locked!",
                photoURL: nil,
                localImageData: nil,
                categoryId: "reflections",
                createdAt: Calendar.current.date(byAdding: .minute, value: -15, to: now) ?? now,
                unlockDate: Calendar.current.date(byAdding: .day, value: 30, to: now) ?? now,
                isOpened: false,
                sealType: .waxSeal
            ),
            
            // 2. Ready to Open Capsule (Available for immediate testing)
            Capsule(
                id: "sample_ready_1",
                userId: "demo_user",
                title: "A Message From Past You",
                message: "If you are reading this, time has traveled forward and brought you here. Take a slow, deep breath. Whatever storms you were fighting on the day this was sealed, you survived them. Be kind to yourself today.",
                photoURL: nil,
                localImageData: nil,
                categoryId: "future_self",
                createdAt: Calendar.current.date(byAdding: .month, value: -6, to: now) ?? now,
                unlockDate: Calendar.current.date(byAdding: .minute, value: -5, to: now) ?? now,
                isOpened: false,
                sealType: .waxSeal
            ),
            
            // 3. Locked Capsule (Created 3 days ago - Grace Window closed, opens in 5 days)
            Capsule(
                id: "sample_locked_1",
                userId: "demo_user",
                title: "Project Milestone Prediction",
                message: "Writing this right before launching the new prototype. My prediction: it won't be flawless, but we will learn ten times faster than before. Let's see how close this forecast was.",
                photoURL: nil,
                localImageData: nil,
                categoryId: "predictions",
                createdAt: Calendar.current.date(byAdding: .day, value: -3, to: now) ?? now,
                unlockDate: Calendar.current.date(byAdding: .day, value: 5, to: now) ?? now,
                isOpened: false,
                sealType: .chronolock
            ),
            
            // 3. Locked Capsule (Opens in 6 months)
            Capsule(
                id: "sample_locked_2",
                userId: "demo_user",
                title: "Letter to My Future Self: Autumn",
                message: "Remember the evening walks by the river, the smell of damp pine, and that quiet café corner where you wrote this. Hold onto the peace you felt here.",
                photoURL: nil,
                localImageData: nil,
                categoryId: "future_self",
                createdAt: now,
                unlockDate: Calendar.current.date(byAdding: .month, value: 6, to: now) ?? now,
                isOpened: false,
                sealType: .envelope
            ),
            
            // 4. Opened Capsule (Timeline memory)
            Capsule(
                id: "sample_opened_1",
                userId: "demo_user",
                title: "First Day in the New Studio",
                message: "Empty cardboard boxes everywhere, no internet yet, drinking cold coffee from a paper cup on the floor. But the light streaming through the south window is extraordinary. This place is going to change everything.",
                photoURL: nil,
                localImageData: nil,
                categoryId: "gratitude",
                createdAt: Calendar.current.date(byAdding: .month, value: -12, to: now) ?? now,
                unlockDate: Calendar.current.date(byAdding: .day, value: -14, to: now) ?? now,
                isOpened: true,
                openedAt: Calendar.current.date(byAdding: .day, value: -14, to: now) ?? now,
                sealType: .waxSeal
            ),
            
            // 5. Opened Capsule (Timeline reflection)
            Capsule(
                id: "sample_opened_2",
                userId: "demo_user",
                title: "A Fear Left Behind",
                message: "I was terrified of speaking on stage today. If you're reading this, it's already done. The dread was far heavier than the reality.",
                photoURL: nil,
                localImageData: nil,
                categoryId: "reflections",
                createdAt: Calendar.current.date(byAdding: .month, value: -8, to: now) ?? now,
                unlockDate: Calendar.current.date(byAdding: .month, value: -2, to: now) ?? now,
                isOpened: true,
                openedAt: Calendar.current.date(byAdding: .month, value: -2, to: now) ?? now,
                sealType: .chronolock
            )
        ]
    }
}

