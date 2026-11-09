import Testing
import Foundation
@testable import TimeCapsule

@Suite("TimeCapsule Domain & Engine Tests")
struct TimeCapsuleTests {
    
    @Test("Capsule lock status correctly identifies locked future date")
    func testCapsuleLockedStatus() {
        let futureDate = Date().addingTimeInterval(3600) // 1 hour in future
        let capsule = Capsule(
            userId: "test_user",
            title: "Future Note",
            message: "Hello tomorrow",
            categoryId: "future_self",
            createdAt: Date(),
            unlockDate: futureDate,
            isOpened: false
        )
        
        let status = capsule.status()
        #expect(status.isLocked)
        #expect(!status.isReadyToOpen)
        #expect(!status.isOpened)
        
        if case .locked(let remaining) = status {
            #expect(remaining > 3500 && remaining <= 3600)
        } else {
            Issue.record("Expected .locked status")
        }
    }
    
    @Test("Capsule lock status transitions to readyToOpen when unlock date is reached")
    func testCapsuleReadyToOpenStatus() {
        let pastDate = Date().addingTimeInterval(-60) // 1 minute in the past
        let capsule = Capsule(
            userId: "test_user",
            title: "Ready Note",
            message: "Open me now",
            categoryId: "future_self",
            createdAt: Date().addingTimeInterval(-86400),
            unlockDate: pastDate,
            isOpened: false
        )
        
        let status = capsule.status()
        #expect(status.isReadyToOpen)
        #expect(!status.isLocked)
        #expect(!status.isOpened)
    }
    
    @Test("Capsule lock status reports opened when isOpened is true regardless of dates")
    func testCapsuleOpenedStatus() {
        let openedDate = Date().addingTimeInterval(-300)
        let capsule = Capsule(
            userId: "test_user",
            title: "Archived Note",
            message: "Already read",
            categoryId: "future_self",
            createdAt: Date().addingTimeInterval(-86400 * 30),
            unlockDate: Date().addingTimeInterval(-86400 * 5),
            isOpened: true,
            openedAt: openedDate
        )
        
        let status = capsule.status()
        #expect(status.isOpened)
        #expect(!status.isLocked)
        #expect(!status.isReadyToOpen)
    }
    
    @Test("Countdown breakdown accurately parses days, hours, minutes and seconds")
    func testCountdownBreakdown() {
        // 2 days + 3 hours + 4 minutes + 5 seconds = 183845 seconds
        let remaining: TimeInterval = (2 * 86400) + (3 * 3600) + (4 * 60) + 5
        let status = TimeLockStatus.locked(remainingTime: remaining)
        
        guard let breakdown = status.countdownBreakdown else {
            Issue.record("Expected breakdown to be available")
            return
        }
        
        #expect(breakdown.days == 2)
        #expect(breakdown.hours == 3)
        #expect(breakdown.minutes == 4)
        #expect(breakdown.seconds == 5)
    }
    
    @Test("PromptService loads categories and prompts without nil failures")
    func testPromptServiceLoad() {
        let service = PromptService()
        let categories = service.loadCategories()
        let prompts = service.loadPrompts()
        
        #expect(!categories.isEmpty)
        #expect(!prompts.isEmpty)
        #expect(categories.contains { $0.id == "future_self" })
    }
    
    @Test("Capsule value semantics guarantee independent copies")
    func testCapsuleValueSemantics() {
        let original = Capsule(
            userId: "user_1",
            title: "Original Title",
            message: "Original Message",
            categoryId: "future_self",
            unlockDate: Date().addingTimeInterval(1000)
        )
        
        var copy = original
        copy.title = "Mutated Title"
        
        #expect(original.title == "Original Title")
        #expect(copy.title == "Mutated Title")
    }
    
    @Test("Capsule permits update and deletion during the 1-hour grace window")
    func testCapsuleGraceWindowActive() {
        let tenMinutesAgo = Date().addingTimeInterval(-600)
        let capsule = Capsule(
            userId: "user_1",
            title: "Grace Capsule",
            message: "Testing grace",
            categoryId: "reflections",
            createdAt: tenMinutesAgo,
            unlockDate: Date().addingTimeInterval(86400),
            isOpened: false
        )
        
        #expect(capsule.isWithinGraceWindow())
        #expect(capsule.canBeUpdated())
        #expect(capsule.canBeDeleted())
        #expect(!capsule.canReadContent()) // Read is still guarded
        
        if let remaining = capsule.remainingGraceTime() {
            #expect(remaining > 2900 && remaining <= 3000) // ~50 minutes left
        } else {
            Issue.record("Expected remaining grace time")
        }
    }
    
    @Test("Capsule locks down update and deletion after the 1-hour grace window has expired")
    func testCapsuleGraceWindowExpired() {
        let twoHoursAgo = Date().addingTimeInterval(-7200)
        let capsule = Capsule(
            userId: "user_1",
            title: "Locked Capsule",
            message: "Testing permanent lock",
            categoryId: "reflections",
            createdAt: twoHoursAgo,
            unlockDate: Date().addingTimeInterval(86400 * 30),
            isOpened: false
        )
        
        #expect(!capsule.isWithinGraceWindow())
        #expect(!capsule.canBeUpdated())
        #expect(!capsule.canBeDeleted())
        #expect(!capsule.canReadContent())
        #expect(capsule.remainingGraceTime() == nil)
    }
    
    @Test("Opened capsule allows reading and deletion even after grace window")
    func testOpenedCapsuleReadAndDelete() {
        let sixMonthsAgo = Date().addingTimeInterval(-86400 * 180)
        let capsule = Capsule(
            userId: "user_1",
            title: "Past Memory",
            message: "Revealed message",
            categoryId: "future_self",
            createdAt: sixMonthsAgo,
            unlockDate: Date().addingTimeInterval(-86400),
            isOpened: true,
            openedAt: Date().addingTimeInterval(-86400)
        )
        
        #expect(capsule.canReadContent())
        #expect(capsule.canBeDeleted()) // Archive/cleanup allowed
        #expect(!capsule.canBeUpdated()) // Cannot edit sealed historical document
    }
}

