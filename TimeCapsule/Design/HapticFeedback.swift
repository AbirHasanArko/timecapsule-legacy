import UIKit

/// Tactical haptic engine ensuring native, physical tactile feedback
/// following Apple Fluid Interface and WWDC principles.
@MainActor
public final class HapticFeedback {
    public static let shared = HapticFeedback()
    
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let rigidImpact = UIImpactFeedbackGenerator(style: .rigid)
    private let softImpact = UIImpactFeedbackGenerator(style: .soft)
    private let selection = UISelectionFeedbackGenerator()
    private let notification = UINotificationFeedbackGenerator()
    
    private init() {
        prepare()
    }
    
    public func prepare() {
        lightImpact.prepare()
        mediumImpact.prepare()
        heavyImpact.prepare()
        rigidImpact.prepare()
        softImpact.prepare()
        selection.prepare()
        notification.prepare()
    }
    
    /// Minor tap or subtle button interaction
    public func light() {
        lightImpact.impactOccurred()
    }
    
    /// Tab change, card selection, prompt flip
    public func selectionChanged() {
        selection.selectionChanged()
    }
    
    /// Tactile latch or lock engagement (closing the capsule)
    public func latchEngaged() {
        rigidImpact.impactOccurred(intensity: 0.9)
    }
    
    /// Soft timer tick or progress heartbeat
    public func tick() {
        softImpact.impactOccurred(intensity: 0.5)
    }
    
    /// Breaking the wax seal or unsealing vault (ceremony climax)
    public func sealBroken() {
        heavyImpact.impactOccurred(intensity: 1.0)
        
        // Secondary resonance vibration for physical reverberation
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 70_000_000) // 70ms
            self.rigidImpact.impactOccurred(intensity: 0.7)
        }
    }
    
    /// Operation successfully completed
    public func success() {
        notification.notificationOccurred(.success)
    }
    
    /// Warning or validation failed
    public func warning() {
        notification.notificationOccurred(.warning)
    }
    
    /// Error
    public func error() {
        notification.notificationOccurred(.error)
    }
}

