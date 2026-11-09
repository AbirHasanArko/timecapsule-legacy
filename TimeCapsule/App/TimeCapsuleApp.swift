import SwiftUI
import UserNotifications

#if canImport(FirebaseCore)
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
            FirebaseApp.configure()
        }
        return true
    }
}
#endif

/// Notification delegate ensuring foreground presentation of unlock alerts.
final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
}

@main
@MainActor
struct TimeCapsuleApp: App {
    #if canImport(FirebaseCore)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    #endif
    
    init() {
        // Pre-warm haptic generators
        HapticFeedback.shared.prepare()
        
        // Wire foreground local notification delegate
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        
        // Request notification authorization asynchronously
        Task { @MainActor in
            _ = await NotificationManager.shared.requestAuthorization()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
