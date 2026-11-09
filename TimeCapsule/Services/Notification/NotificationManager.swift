import Foundation
import UserNotifications

/// Manager handling local notification scheduling when capsules reach their unlock date.
@MainActor
public final class NotificationManager: ObservableObject {
    public static let shared = NotificationManager()
    
    @Published public var isAuthorized: Bool = false
    
    private init() {
        Task {
            await checkAuthorization()
        }
    }
    
    /// Requests notification permissions from the user
    @discardableResult
    public func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            self.isAuthorized = granted
            return granted
        } catch {
            self.isAuthorized = false
            return false
        }
    }
    
    /// Checks current authorization status
    public func checkAuthorization() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        self.isAuthorized = (settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional)
    }
    
    /// Schedules a local notification for the capsule's scheduled unlock date
    public func scheduleNotification(for capsule: Capsule) async {
        // Only schedule if unlock date is in the future and capsule is not already opened
        guard !capsule.isOpened, capsule.unlockDate > Date() else { return }
        
        // Ensure permission is granted
        if !isAuthorized {
            let granted = await requestAuthorization()
            guard granted else { return }
        }
        
        let content = UNMutableNotificationContent()
        content.title = "TimeCapsule Ready to Unseal ⏳"
        content.body = "Your capsule \"\(capsule.title)\" has unlocked! Tap to break the seal and read your past memory."
        content.sound = .default
        content.userInfo = [
            "capsuleId": capsule.id,
            "type": "capsule_unlocked"
        ]
        
        let timeInterval = capsule.unlockDate.timeIntervalSinceNow
        guard timeInterval > 0 else { return }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(
            identifier: notificationIdentifier(for: capsule.id),
            content: content,
            trigger: trigger
        )
        
        try? await UNUserNotificationCenter.current().add(request)
    }
    
    /// Cancels scheduled notification if a capsule is deleted or edited
    public func cancelNotification(for capsuleId: String) {
        let identifier = notificationIdentifier(for: capsuleId)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    /// Updates scheduled notification with a new unlock date
    public func updateNotification(for capsule: Capsule) async {
        cancelNotification(for: capsule.id)
        await scheduleNotification(for: capsule)
    }
    
    /// Sends a test notification after `delaySeconds` for simulator testing
    public func sendTestNotification(delaySeconds: TimeInterval = 5) async {
        let granted = await requestAuthorization()
        guard granted else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "TimeCapsule Notification Test 🔔"
        content.body = "This is a preview of how notifications appear when your sealed capsules unlock!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, delaySeconds), repeats: false)
        let request = UNNotificationRequest(
            identifier: "test_notification_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        try? await UNUserNotificationCenter.current().add(request)
    }
    
    private func notificationIdentifier(for capsuleId: String) -> String {
        "timecapsule_unlock_\(capsuleId)"
    }
}

