import SwiftUI
import UIKit

/// Tactile unsealing ceremony simulating the physical breaking of a wax seal or vault latch.
public struct UnsealingCeremonyView: View {
    let capsule: Capsule
    let onOpened: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var pressProgress: Double = 0.0
    @State private var isHolding: Bool = false
    @State private var isUnsealed: Bool = false
    @State private var showLetterContent: Bool = false
    
    public init(capsule: Capsule, onOpened: @escaping () -> Void) {
        self.capsule = capsule
        self.onOpened = onOpened
    }
    
    public var body: some View {
        ZStack {
            Theme.Colors.adaptiveBackground
                .ignoresSafeArea()
            
            if isUnsealed {
                // Revealed Capsule Content
                revealedLetterView
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.96)),
                        removal: .opacity
                    ))
            } else {
                // Unsealing Ceremony Interaction
                ceremonyVaultView
                    .transition(.opacity)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    dismiss()
                }
                .font(Theme.Typography.headline)
                .foregroundColor(Theme.Colors.terracotta)
            }
        }
    }
    
    // MARK: - Ceremony Vault View
    private var ceremonyVaultView: some View {
        VStack(spacing: 36) {
            Spacer()
            
            // Header
            VStack(spacing: 10) {
                Text(capsule.title)
                    .font(Theme.Typography.serifLargeTitle)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                
                Text("Sealed on \(capsule.createdAt.formatted(date: .long, time: .omitted))")
                    .font(Theme.Typography.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Interactive Physical Seal
            VStack(spacing: 24) {
                ZStack {
                    // Ambient Glow when holding
                    Circle()
                        .fill(sealAccentColor.opacity(0.25))
                        .frame(width: 190, height: 190)
                        .scaleEffect(1.0 + (pressProgress * 0.35))
                        .blur(radius: 20)
                    
                    // Outer Ring / Dial
                    Circle()
                        .strokeBorder(Theme.Colors.adaptiveBorder, lineWidth: 3)
                        .frame(width: 160, height: 160)
                    
                    // Progress Arc
                    Circle()
                        .trim(from: 0.0, to: pressProgress)
                        .stroke(
                            sealAccentColor,
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .frame(width: 160, height: 160)
                        .rotationEffect(.degrees(-90))
                    
                    // Central Wax Seal / Chrono Disc
                    Circle()
                        .fill(sealAccentColor)
                        .frame(width: 130, height: 130)
                        .shadow(color: sealAccentColor.opacity(0.4), radius: 16, x: 0, y: 8)
                        .overlay(
                            VStack(spacing: 6) {
                                Image(systemName: capsule.sealType.iconName)
                                    .font(.system(size: 38, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text(capsule.sealType.displayName.uppercased())
                                    .font(.system(size: 9, weight: .heavy))
                                    .foregroundColor(.white.opacity(0.85))
                                    .tracking(1.5)
                            }
                        )
                        .scaleEffect(isHolding ? 0.94 : 1.0)
                }
                .frame(width: 190, height: 190)
                .onLongPressGesture(
                    minimumDuration: 1.5,
                    pressing: { pressing in
                        self.isHolding = pressing
                        if pressing {
                            startHoldFeedback()
                        } else if !isUnsealed {
                            withAnimation(Theme.AnimationCurve.gestureSpring) {
                                pressProgress = 0.0
                            }
                        }
                    },
                    perform: {
                        triggerUnseal()
                    }
                )
                
                // Instructions
                VStack(spacing: 6) {
                    Text("Press & Hold to Break the Seal")
                        .font(Theme.Typography.headline)
                        .foregroundColor(.primary)
                    
                    Text("The time has come to unlock your past memory.")
                        .font(Theme.Typography.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            Spacer()
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Revealed Letter View
    private var revealedLetterView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                // Header badge
                HStack {
                    Label("Unsealed", systemImage: "lock.open.fill")
                        .font(Theme.Typography.caption)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.Colors.emerald)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Theme.Colors.emerald.opacity(0.12))
                        .clipShape(Capsule())
                    
                    Spacer()
                    
                    Text(Date().formatted(date: .abbreviated, time: .shortened))
                        .font(Theme.Typography.caption)
                        .foregroundColor(.secondary)
                }
                
                // Title
                Text(capsule.title)
                    .font(Theme.Typography.serifLargeTitle)
                    .foregroundColor(.primary)
                
                // Timestamp comparison
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("SEALED")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.secondary)
                        Text(capsule.createdAt.formatted(date: .abbreviated, time: .omitted))
                            .font(Theme.Typography.subheadline)
                    }
                    
                    Image(systemName: "arrow.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("OPENED TODAY")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Theme.Colors.emerald)
                        Text(Date().formatted(date: .abbreviated, time: .omitted))
                            .font(Theme.Typography.subheadline)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 14)
                .background(Theme.Colors.adaptiveCard)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Theme.Colors.adaptiveBorder, lineWidth: 1)
                )
                
                // Photo Attachment if present
                if let imageData = capsule.localImageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: Theme.Dimensions.cardCornerRadius, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.Dimensions.cardCornerRadius, style: .continuous)
                                .strokeBorder(Theme.Colors.adaptiveBorder, lineWidth: 1)
                        )
                }
                
                // Letter Message in Editorial Serif
                Text(capsule.message)
                    .font(Theme.Typography.serifBody)
                    .lineSpacing(8)
                    .foregroundColor(.primary)
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.Colors.adaptiveCard)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Dimensions.cardCornerRadius, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.Dimensions.cardCornerRadius, style: .continuous)
                            .strokeBorder(Theme.Colors.adaptiveBorder, lineWidth: 1)
                    )
                
                // Reflection Footer
                VStack(alignment: .center, spacing: 10) {
                    Text("This memory is now permanently archived in your Timeline.")
                        .font(Theme.Typography.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
                .padding(.top, 16)
            }
            .padding(24)
        }
    }
    
    private var sealAccentColor: Color {
        switch capsule.sealType {
        case .waxSeal: return Theme.Colors.waxCrimson
        case .chronolock: return Theme.Colors.vaultGraphite
        case .envelope: return Theme.Colors.terracotta
        }
    }
    
    private func startHoldFeedback() {
        HapticFeedback.shared.latchEngaged()
        withAnimation(.linear(duration: 1.5)) {
            pressProgress = 1.0
        }
    }
    
    private func triggerUnseal() {
        HapticFeedback.shared.sealBroken()
        withAnimation(Theme.AnimationCurve.sealCeremony) {
            isUnsealed = true
        }
        onOpened()
    }
}

