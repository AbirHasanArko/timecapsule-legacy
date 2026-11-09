import SwiftUI

/// Stable, monospaced countdown badge that prevents layout jitter while seconds tick down.
public struct CountdownBadgeView: View {
    let status: TimeLockStatus
    @State private var isPulsing: Bool = false
    
    public init(status: TimeLockStatus) {
        self.status = status
    }
    
    public var body: some View {
        HStack(spacing: 6) {
            switch status {
            case .readyToOpen:
                Circle()
                    .fill(Theme.Colors.emerald)
                    .frame(width: 8, height: 8)
                    .scaleEffect(isPulsing ? 1.3 : 1.0)
                    .opacity(isPulsing ? 0.7 : 1.0)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                            isPulsing = true
                        }
                    }
                
                Text("READY TO UNSEAL")
                    .font(Theme.Typography.countdownBadge)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.Colors.emerald)
                
            case .locked:
                Image(systemName: "lock.fill")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Theme.Colors.antiqueGold)
                
                if let breakdown = status.countdownBreakdown {
                    if breakdown.days > 0 {
                        Text("\(breakdown.days)d \(String(format: "%02d", breakdown.hours))h \(String(format: "%02d", breakdown.minutes))m")
                            .font(Theme.Typography.countdownBadge)
                            .monospacedDigit()
                            .foregroundColor(Theme.Colors.antiqueGold)
                    } else {
                        Text("\(String(format: "%02d", breakdown.hours))h \(String(format: "%02d", breakdown.minutes))m \(String(format: "%02d", breakdown.seconds))s")
                            .font(Theme.Typography.countdownBadge)
                            .monospacedDigit()
                            .foregroundColor(Theme.Colors.antiqueGold)
                    }
                } else {
                    Text(status.humanizedDescription)
                        .font(Theme.Typography.countdownBadge)
                        .foregroundColor(Theme.Colors.antiqueGold)
                }
                
            case .opened(let date):
                Image(systemName: "lock.open.fill")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
                
                Text(date.formatted(date: .abbreviated, time: .omitted))
                    .font(Theme.Typography.countdownBadge)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(badgeBackgroundColor)
        )
        .overlay(
            Capsule()
                .strokeBorder(badgeBorderColor, lineWidth: 1)
        )
    }
    
    private var badgeBackgroundColor: Color {
        switch status {
        case .readyToOpen:
            return Theme.Colors.emerald.opacity(0.12)
        case .locked:
            return Theme.Colors.antiqueGold.opacity(0.12)
        case .opened:
            return Color.secondary.opacity(0.10)
        }
    }
    
    private var badgeBorderColor: Color {
        switch status {
        case .readyToOpen:
            return Theme.Colors.emerald.opacity(0.3)
        case .locked:
            return Theme.Colors.antiqueGold.opacity(0.25)
        case .opened:
            return Color.secondary.opacity(0.2)
        }
    }
}

