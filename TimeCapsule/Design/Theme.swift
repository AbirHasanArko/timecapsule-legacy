import SwiftUI

/// Central design system tokens for TimeCapsule following Apple Human Interface Guidelines
/// and Emil Kowalski design engineering principles (restraint, tactile feedback, materials).
public enum Theme {
    // MARK: - Colors
    public enum Colors {
        /// Primary canvas background (warm parchment in light mode, obsidian slate in dark mode)
        public static var background: Color { adaptiveBackground }
        
        /// Secondary surface for cards, envelopes, and sheet containers
        public static var cardBackground: Color { adaptiveCard }
        
        /// Tertiary elevated surfaces
        public static var elevatedBackground: Color { adaptiveCard }
        
        /// Primary ink text
        public static var ink: Color { Color.primary }
        
        /// Muted secondary text
        public static var mutedInk: Color { Color.secondary }
        
        /// Warm terracotta accent (heritage letters, unsealed status)
        public static let terracotta = Color(red: 0.85, green: 0.47, blue: 0.21)
        
        /// Antique gold (milestones, active countdowns)
        public static let antiqueGold = Color(red: 0.78, green: 0.62, blue: 0.28)
        
        /// Vault graphite (locked states, security)
        public static let vaultGraphite = Color(red: 0.32, green: 0.35, blue: 0.40)
        
        /// Crimson wax seal
        public static let waxCrimson = Color(red: 0.72, green: 0.22, blue: 0.20)
        
        /// Success emerald
        public static let emerald = Color(red: 0.18, green: 0.62, blue: 0.41)
        
        // Fallback adaptive colors if Asset Catalog colors are not compiled
        public static var adaptiveBackground: Color {
            Color(uiColor: UIColor { trait in
                trait.userInterfaceStyle == .dark
                    ? UIColor(red: 0.06, green: 0.06, blue: 0.07, alpha: 1.0)
                    : UIColor(red: 0.98, green: 0.97, blue: 0.95, alpha: 1.0)
            })
        }
        
        public static var adaptiveCard: Color {
            Color(uiColor: UIColor { trait in
                trait.userInterfaceStyle == .dark
                    ? UIColor(red: 0.11, green: 0.11, blue: 0.13, alpha: 1.0)
                    : UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            })
        }
        
        public static var adaptiveBorder: Color {
            Color.primary.opacity(0.08)
        }
    }
    
    // MARK: - Typography
    public enum Typography {
        /// Editorial title for memory letters and ceremonies
        public static let serifLargeTitle = Font.system(.largeTitle, design: .serif).weight(.medium)
        public static let serifTitle = Font.system(.title2, design: .serif).weight(.semibold)
        public static let serifBody = Font.system(.body, design: .serif)
        public static let serifQuote = Font.system(.callout, design: .serif).italic()
        
        /// System interface fonts
        public static let headline = Font.system(.headline, design: .default)
        public static let subheadline = Font.system(.subheadline, design: .default)
        public static let caption = Font.system(.caption, design: .default)
        
        /// Strict monospaced numbers for timer stability
        public static let countdown = Font.system(.title3, design: .monospaced).weight(.semibold)
        public static let countdownLarge = Font.system(.system(size: 32), design: .monospaced).weight(.bold)
        public static let countdownBadge = Font.system(.caption, design: .monospaced).weight(.medium)
    }
    
    // MARK: - Curves & Animation Timing
    public enum AnimationCurve {
        /// Natural velocity-inheriting spring for interactive gestures
        public static let gestureSpring = Animation.spring(response: 0.38, dampingFraction: 0.82)
        
        /// Dramatic spring for breaking seals and unsealing ceremony
        public static let sealCeremony = Animation.spring(response: 0.55, dampingFraction: 0.72)
        
        /// Fast tactile response for button press
        public static let tactilePress = Animation.easeOut(duration: 0.12)
        
        /// Smooth opacity fade
        public static let crossFade = Animation.easeInOut(duration: 0.25)
    }
    
    // MARK: - Radii & Layout
    public enum Dimensions {
        public static let cardCornerRadius: CGFloat = 20
        public static let buttonCornerRadius: CGFloat = 14
        public static let pillCornerRadius: CGFloat = 24
        public static let standardPadding: CGFloat = 16
        public static let widePadding: CGFloat = 24
    }
}

// MARK: - View Modifiers for High-Craft UI
public struct CardSurfaceModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    var cornerRadius: CGFloat = Theme.Dimensions.cardCornerRadius
    
    public func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Theme.Colors.adaptiveCard)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Theme.Colors.adaptiveBorder, lineWidth: 1)
            )
            .shadow(
                color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.05),
                radius: 12,
                x: 0,
                y: 4
            )
    }
}

public extension View {
    func cardSurface(cornerRadius: CGFloat = Theme.Dimensions.cardCornerRadius) -> some View {
        modifier(CardSurfaceModifier(cornerRadius: cornerRadius))
    }
}

