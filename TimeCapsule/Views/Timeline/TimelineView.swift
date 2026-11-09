import SwiftUI

/// Chronological gallery of unsealed capsules and past reflections.
public struct TimelineView: View {
    let capsules: [Capsule]
    @Environment(\.dismiss) private var dismiss
    
    public init(capsules: [Capsule]) {
        // Sort chronologically descending by opened date
        self.capsules = capsules.sorted { ($0.openedAt ?? $0.unlockDate) > ($1.openedAt ?? $1.unlockDate) }
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header Description
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Memory Timeline")
                            .font(Theme.Typography.serifLargeTitle)
                            .foregroundColor(.primary)
                        
                        Text("A chronological tapestry of past thoughts, predictions, and unsealed letters.")
                            .font(Theme.Typography.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    
                    if capsules.isEmpty {
                        emptyTimelineView
                    } else {
                        VStack(spacing: 0) {
                            ForEach(Array(capsules.enumerated()), id: \.element.id) { index, capsule in
                                TimelineItemView(
                                    capsule: capsule,
                                    isLast: index == capsules.count - 1
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                    }
                }
                .padding(.bottom, 40)
            }
            .background(Theme.Colors.adaptiveBackground.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .font(Theme.Typography.headline)
                    .foregroundColor(Theme.Colors.terracotta)
                }
            }
        }
    }
    
    private var emptyTimelineView: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 60)
            
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 44))
                .foregroundColor(.secondary.opacity(0.6))
            
            Text("No Memories Unsealed Yet")
                .font(Theme.Typography.serifTitle)
                .foregroundColor(.primary)
            
            Text("Once your locked capsules reach their unlock date and you break their seals, they will appear here in chronological order.")
                .font(Theme.Typography.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 36)
        }
    }
}

