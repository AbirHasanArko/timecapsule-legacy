# TimeCapsule — Digital Time-Locked Memory App (iOS)

> *"Write a letter to your future self today, seal it, and unlock it six months later."*

A native iOS app built in modern Swift and SwiftUI adhering strictly to **Apple Fluid Interface** and **Design Engineering** principles. The app emphasizes tactile physical metaphors (wax seal, chrono vault, parchment folds), typography, and monospaced non-jittering countdowns.

---

## 📱 Features

1. **Authentication**: Register, sign in, sign out with Firebase Authentication (includes a zero-config **Guest Demo Mode** for immediate testing without network credentials).
2. **Capsule Creation Studio (Create)**: Title, letter body, photo attachment, and target date locking.
3. **Timed Update & Delete Window (30m - 1h Grace Window)**:
   - When sealed, users have a **1-hour grace window** to edit text, change unlock dates, replace photos, or delete/cancel the capsule.
   - Once the grace window closes, the capsule enters **Ironclad Lock**: it cannot be edited, and deletion is prohibited to preserve the emotional commitment.
4. **Guarded Read Access (Read)**:
   - Letters and photos remain completely sealed and redacted until the scheduled unlock date arrives and the unsealing ceremony is completed.
5. **Local Notifications (`UNUserNotificationCenter`)**:
   - The app automatically schedules a high-priority local notification when each capsule's unlock date arrives.
   - Includes foreground banner handling and an instant **"Test Notification (5s)"** action in the dashboard menu.
6. **Inspirational Prompts Carousel**: Bundled JSON card deck with reflective questions you can tap to inject into your letters.
7. **Time Lock Engine**: Monospaced countdowns (`05d 14h 23m 10s`) that update live each second without jitter or layout shifts.
8. **My Capsules Dashboard**: Fast categorization between **Ready to Open**, **Locked**, and **Unsealed**.
9. **Tactile Unsealing Ceremony**: Press-and-hold ceremony with resonant haptics, spring physics, and dramatic unfolding reveal.
10. **Memory Timeline**: Chronological archive of previously opened capsules showing original creation dates, time sealed, and reflections.
11. **Cloud Sync & Fallback**: Cloud Firestore and Firebase Storage integration with an in-memory mock repository fallback.

---

## 🛠 Project Structure

```text
TimeCapsule/
├── App/
│   ├── TimeCapsuleApp.swift                 # App entry point with Firebase setup
│   └── ContentView.swift                    # Root router with fluid transition
├── Models/
│   ├── Capsule.swift                        # Core value-type model
│   ├── CapsuleCategory.swift                # Theme categories & custom hex colors
│   ├── InspirationalPrompt.swift            # Prompt schema
│   └── TimeLockStatus.swift                 # Dynamic status engine & countdown math
├── Services/
│   ├── Auth/
│   │   ├── AuthServiceProtocol.swift        # Auth interface
│   │   ├── FirebaseAuthService.swift        # Production Firebase Auth
│   │   └── MockAuthService.swift            # Offline / Demo session
│   ├── Storage/
│   │   ├── CapsuleRepositoryProtocol.swift  # Storage interface
│   │   ├── FirestoreCapsuleService.swift    # Production Cloud Firestore
│   │   └── MockCapsuleRepository.swift      # In-memory mock with sample data
│   ├── Media/
│   │   └── FirebaseStorageService.swift     # Photo upload to Firebase Storage
│   └── Seed/
│       └── PromptService.swift              # JSON loader for prompts & categories
├── ViewModels/
│   ├── AuthViewModel.swift                  # Session & validation logic
│   ├── DashboardViewModel.swift             # Live timer & filtering
│   └── CreateCapsuleViewModel.swift         # Sealing progress & draft state
├── Views/
│   ├── Auth/
│   │   ├── LoginView.swift                  # Editorial login & guest button
│   │   └── RegisterView.swift               # Registration form
│   ├── Dashboard/
│   │   ├── DashboardView.swift              # Main hub
│   │   └── Components/
│   │       ├── CapsuleCardView.swift        # Capsule card
│   │       └── CountdownBadgeView.swift     # Monospaced status pill
│   ├── Create/
│   │   ├── CreateCapsuleView.swift          # Writing studio
│   │   └── Components/
│   │       ├── PromptCarouselView.swift     # Horizontal prompt deck
│   │       └── SealPickerView.swift         # Physical seal picker
│   ├── Ceremony/
│   │   ├── CapsuleDetailView.swift          # Vault & countdown view
│   │   └── UnsealingCeremonyView.swift      # Interactive seal breaking
│   └── Timeline/
│       ├── TimelineView.swift               # Chronological past memories
│       └── TimelineItemView.swift           # Timeline rail node
├── Design/
│   ├── Theme.swift                          # Colors, typography, curves, borders
│   └── HapticFeedback.swift                 # Physical tactile haptic generator
└── Resources/
    ├── SeedData/
    │   ├── categories.json                  # Bundled category definitions
    │   └── prompts.json                     # Bundled reflective prompts
    └── Assets.xcassets                      # App icon & color catalog
```

---

## 🚀 How to Run in Xcode on Mac

### Option 1: Open the Xcode Project (Recommended)
1. Copy or transfer the project folder to the Mac.
2. Double-click **`TimeCapsule.xcodeproj`** to open it in Xcode.
3. Select an iOS Simulator (e.g., iPhone 16 Pro running iOS 17 or iOS 18).
4. Press **`Cmd + R`** to build and run!
   - The app will run out of the box in **Demo Mode** with pre-seeded locked, ready-to-unseal, and opened capsules.
   - Tap **"Explore as Guest"** or log in with any sample email.
   - Tap **"A Message From Past You"** to immediately test the **Unsealing Ceremony** with spring animations and haptics!

### Option 2: Open as a Swift Package
1. In Xcode, choose **File > Open...**
2. Select the `TimeCapsule` folder (containing `Package.swift`).
3. Xcode will automatically resolve the Firebase iOS SDK package.

---

## ☁️ Connecting Live Firebase (Optional)

1. Create a project in the [Firebase Console](https://console.firebase.google.com).
2. Add an iOS app with Bundle ID: `com.timecapsule.app`.
3. Enable:
   - **Authentication** (Email/Password)
   - **Cloud Firestore**
   - **Firebase Storage**
4. Download your **`GoogleService-Info.plist`** file from Firebase.
5. Drag and drop **`GoogleService-Info.plist`** into `TimeCapsule/Resources/` in Xcode, making sure *"Copy items if needed"* is checked.
6. Build and run — the app will automatically detect the plist and switch from the mock repository to live Firestore synchronization!

---

## 🧪 Testing

To run the Swift Testing suite:
- In Xcode, press **`Cmd + U`** or open the **Test Navigator** (`Cmd + 6`) and run `TimeCapsuleTests`.
- The tests verify time-lock status calculations, monospaced countdown arithmetic, JSON decoding resilience, and value-type isolation.

