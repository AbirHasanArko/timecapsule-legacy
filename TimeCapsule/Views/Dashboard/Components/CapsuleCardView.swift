import SwiftUI

/// Elegant card displaying a capsule with tactile elevation, seal emblem, and dynamic status.
public struct CapsuleCardView: View {
    let capsule: Capsule
    let referenceDate: Date
    let category: CapsuleCategory?
    
    public init(capsule: Capsule, referenceDate: Date, category: CapsuleCategory? = nil) {
        self.capsule = capsule
        self.referenceDate = referenceDate
        self.category = category
    }
    
    private var status: TimeLockStatus {
        capsule.status(at: referenceDate)
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Top Row: Category + Seal Emblem + Countdown Badge
            HStack(alignment: .center) {
                HStack(spacing: 6) {
                    Image(systemName: category?.icon ?? capsule.sealType.iconName)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(category?.accentColor ?? Theme.Colors.terracotta)
                    
                    Text(category?.name ?? "Memory")
                        .font(Theme.Typography.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                CountdownBadgeView(status: status)
            }
            
            // Middle: Title & Content Preview
            VStack(alignment: .leading, spacing: 6) {
                Text(capsule.title)
                    .font(Theme.Typography.serifTitle)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                if status.isOpened {
                    Text(capsule.message)
                        .font(Theme.Typography.serifBody)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                } else {
                    HStack(spacing: 6) {
                        Image(systemName: "lock.shield")
                            .font(.system(size: 11))
                        Text(status.isReadyToOpen ? "Time has arrived. Tap to break the seal." : "Contents sealed until unlock date.")
                            .font(Theme.Typography.caption)
                    }
                    .foregroundColor(status.isReadyToOpen ? Theme.Colors.emerald : .secondary)
                }
            }
            
            Divider()
                .background(Theme.Colors.adaptiveBorder)
            
            // Bottom Row: Created Date, Grace Window badge & Seal Type
            HStack {
                Text("Sealed \(capsule.createdAt.formatted(date: .abbreviated, time: .omitted))")
                    .font(Theme.Typography.caption)
                    .foregroundColor(.secondary)
                
                if capsule.isWithinGraceWindow(at: referenceDate) {
                    HStack(spacing: 3) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 10))
                        Text(capsule.formattedRemainingGraceTime(at: referenceDate) ?? "")
                            .font(.system(size: 10, design: .monospaced))
                    }
                    .foregroundColor(Theme.Colors.terracotta)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Theme.Colors.terracotta.opacity(0.12))
                    .clipShape(SwiftUI.Capsule())
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: capsule.sealType.iconName)
                        .font(.system(size: 12))
                    Text(capsule.sealType.displayName)
                        .font(Theme.Typography.caption)
                }
                .foregroundColor(.secondary)
            }
        }
        .padding(18)
        .cardSurface()
    }
}

