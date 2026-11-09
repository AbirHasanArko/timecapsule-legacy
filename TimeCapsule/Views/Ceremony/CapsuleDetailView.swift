import SwiftUI
import UIKit

/// Detail screen presenting a locked, ready-to-open, or unsealed capsule
/// with timed grace window controls and strict read protection.
public struct CapsuleDetailView: View {
    let capsule: Capsule
    let referenceDate: Date
    let onMarkOpened: () -> Void
    var onUpdate: ((Capsule) -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    
    @Environment(\.dismiss) private var dismiss
    @State private var isShowingCeremony: Bool = false
    @State private var isShowingEditSheet: Bool = false
    @State private var isShowingDeleteAlert: Bool = false
    @State private var isShowingCannotDeleteAlert: Bool = false
    
    public init(
        capsule: Capsule,
        referenceDate: Date,
        onMarkOpened: @escaping () -> Void,
        onUpdate: ((Capsule) -> Void)? = nil,
        onDelete: (() -> Void)? = nil
    ) {
        self.capsule = capsule
        self.referenceDate = referenceDate
        self.onMarkOpened = onMarkOpened
        self.onUpdate = onUpdate
        self.onDelete = onDelete
    }
    
    private var status: TimeLockStatus {
        capsule.status(at: referenceDate)
    }
    
    private var isGraceWindowActive: Bool {
        capsule.canBeUpdated(at: referenceDate)
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                // Status Header
                HStack {
                    CountdownBadgeView(status: status)
                    Spacer()
                    Text("Sealed \(capsule.createdAt.formatted(date: .abbreviated, time: .omitted))")
                        .font(Theme.Typography.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 24)
                
                // Capsule Hero Icon / Vault Shield
                ZStack {
                    Circle()
                        .fill(heroAccentColor.opacity(0.12))
                        .frame(width: 130, height: 130)
                    
                    Circle()
                        .strokeBorder(heroAccentColor.opacity(0.3), lineWidth: 2)
                        .frame(width: 130, height: 130)
                    
                    Image(systemName: status.isOpened ? "lock.open.fill" : capsule.sealType.iconName)
                        .font(.system(size: 50, weight: .semibold))
                        .foregroundColor(heroAccentColor)
                }
                .padding(.top, 8)
                
                // Title
                Text(capsule.title)
                    .font(Theme.Typography.serifLargeTitle)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                
                // Timed Grace Window Badge (If Locked)
                if !status.isOpened {
                    graceWindowNoticeView
                        .padding(.horizontal, 24)
                }
                
                if status.isOpened {
                    // READ ACCESS: Opened Memory View
                    revealedContentView
                        .padding(.horizontal, 24)
                    
                } else if status.isReadyToOpen {
                    // Ready to Open Call to Action
                    VStack(spacing: 16) {
                        Text("The scheduled unlock date has arrived.")
                            .font(Theme.Typography.subheadline)
                            .foregroundColor(.secondary)
                        
                        Button {
                            isShowingCeremony = true
                        } label: {
                            Label("Begin Unsealing Ceremony", systemImage: "sparkles")
                        }
                        .tactilePrimary()
                    }
                    .padding(24)
                    .cardSurface()
                    .padding(.horizontal, 24)
                    
                } else {
                    // READ PROTECTED: Locked Vault View with Live Timer
                    lockedVaultView
                        .padding(.horizontal, 24)
                }
            }
            .padding(.vertical, 20)
        }
        .background(Theme.Colors.adaptiveBackground.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    if isGraceWindowActive {
                        Button {
                            isShowingEditSheet = true
                        } label: {
                            Label("Edit Capsule (Window Active)", systemImage: "pencil")
                        }
                    }
                    
                    Button(role: .destructive) {
                        if capsule.canBeDeleted(at: referenceDate) {
                            isShowingDeleteAlert = true
                        } else {
                            isShowingCannotDeleteAlert = true
                        }
                    } label: {
                        Label("Delete Capsule", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 18))
                        .foregroundColor(.primary)
                }
            }
        }
        .sheet(isPresented: $isShowingEditSheet) {
            EditCapsuleView(capsule: capsule) { updated in
                onUpdate?(updated)
            }
        }
        .fullScreenCover(isPresented: $isShowingCeremony) {
            UnsealingCeremonyView(capsule: capsule) {
                onMarkOpened()
            }
        }
        .alert("Delete Capsule", isPresented: $isShowingDeleteAlert) {
            Button("Delete", role: .destructive) {
                onDelete?()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this capsule? This action cannot be undone.")
        }
        .alert("Capsule Locked in Time", isPresented: $isShowingCannotDeleteAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("The 1-hour grace window to delete this capsule has closed. To preserve the emotional integrity of your time lock, it can only be deleted once it unlocks.")
        }
    }
    
    // MARK: - Grace Window Notice
    private var graceWindowNoticeView: some View {
        HStack(spacing: 12) {
            Image(systemName: isGraceWindowActive ? "clock.badge.checkmark" : "lock.fill")
                .foregroundColor(isGraceWindowActive ? Theme.Colors.terracotta : .secondary)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(isGraceWindowActive ? "Edit & Cancel Window Active" : "Ironclad Time Lock")
                    .font(Theme.Typography.caption)
                    .fontWeight(.bold)
                    .foregroundColor(isGraceWindowActive ? Theme.Colors.terracotta : .secondary)
                
                if isGraceWindowActive, let remaining = capsule.formattedRemainingGraceTime(at: referenceDate) {
                    Text("\(remaining) left to edit or cancel before permanent lock")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.secondary)
                } else {
                    Text("Modification window has closed. Contents sealed until unlock date.")
                        .font(Theme.Typography.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if isGraceWindowActive {
                Button("Edit") {
                    isShowingEditSheet = true
                }
                .font(Theme.Typography.caption)
                .fontWeight(.bold)
                .foregroundColor(Theme.Colors.terracotta)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Theme.Colors.terracotta.opacity(0.12))
                .clipShape(SwiftUI.Capsule())
            }
        }
        .padding(12)
        .cardSurface(cornerRadius: 14)
    }
    
    // MARK: - Read Protected Locked View
    private var lockedVaultView: some View {
        VStack(spacing: 20) {
            Text("TIME UNTIL UNSEAL")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.5)
                .foregroundColor(.secondary)
            
            if let breakdown = status.countdownBreakdown {
                HStack(spacing: 12) {
                    timerColumn(value: breakdown.days, label: "DAYS")
                    timerDivider
                    timerColumn(value: breakdown.hours, label: "HOURS")
                    timerDivider
                    timerColumn(value: breakdown.minutes, label: "MIN")
                    timerDivider
                    timerColumn(value: breakdown.seconds, label: "SEC")
                }
                .padding(.vertical, 8)
            }
            
            Divider()
                .background(Theme.Colors.adaptiveBorder)
            
            VStack(spacing: 6) {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(Theme.Colors.antiqueGold)
                    Text("Unlocks on \(capsule.unlockDate.formatted(date: .long, time: .shortened))")
                        .font(Theme.Typography.caption)
                        .foregroundColor(.secondary)
                }
                
                Text("Messages and photos remain sealed until this date.")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary.opacity(0.7))
            }
        }
        .padding(24)
        .cardSurface()
    }
    
    // MARK: - Revealed Content View
    private var revealedContentView: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let imageData = capsule.localImageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Dimensions.cardCornerRadius, style: .continuous))
            }
            
            Text(capsule.message)
                .font(Theme.Typography.serifBody)
                .lineSpacing(8)
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .cardSurface()
        }
    }
    
    private var heroAccentColor: Color {
        if status.isOpened {
            return Theme.Colors.emerald
        } else if status.isReadyToOpen {
            return Theme.Colors.terracotta
        } else {
            return Theme.Colors.antiqueGold
        }
    }
    
    private func timerColumn(value: Int, label: String) -> some View {
        VStack(spacing: 4) {
            Text(String(format: "%02d", value))
                .font(Theme.Typography.countdown)
                .monospacedDigit()
                .foregroundColor(.primary)
            
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.secondary)
        }
        .frame(minWidth: 44)
    }
    
    private var timerDivider: some View {
        Text(":")
            .font(Theme.Typography.countdown)
            .foregroundColor(.secondary.opacity(0.5))
            .offset(y: -8)
    }
}
