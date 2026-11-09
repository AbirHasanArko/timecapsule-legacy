import SwiftUI

/// Tactile button style adhering to Apple Design: immediate pointer-down scale feedback
/// with zero tap lag and native haptic accompaniment.
public struct TactileButtonStyle: ButtonStyle {
    var isPrimary: Bool = true
    var cornerRadius: CGFloat = Theme.Dimensions.buttonCornerRadius
    
    public init(isPrimary: Bool = true, cornerRadius: CGFloat = Theme.Dimensions.buttonCornerRadius) {
        self.isPrimary = isPrimary
        self.cornerRadius = cornerRadius
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.Typography.headline)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(isPrimary ? Theme.Colors.terracotta : Theme.Colors.adaptiveCard)
            )
            .foregroundColor(isPrimary ? .white : .primary)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(isPrimary ? Color.clear : Theme.Colors.adaptiveBorder, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(Theme.AnimationCurve.tactilePress, value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, isPressed in
                if isPressed {
                    HapticFeedback.shared.light()
                }
            }
    }
}

public extension Button {
    func tactilePrimary(cornerRadius: CGFloat = Theme.Dimensions.buttonCornerRadius) -> some View {
        buttonStyle(TactileButtonStyle(isPrimary: true, cornerRadius: cornerRadius))
    }
    
    func tactileSecondary(cornerRadius: CGFloat = Theme.Dimensions.buttonCornerRadius) -> some View {
        buttonStyle(TactileButtonStyle(isPrimary: false, cornerRadius: cornerRadius))
    }
}

