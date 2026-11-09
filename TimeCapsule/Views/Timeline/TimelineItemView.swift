import SwiftUI
import UIKit

/// Single chronological timeline node with vertical connector and memory card.
public struct TimelineItemView: View {
    let capsule: Capsule
    let isLast: Bool
    
    public init(capsule: Capsule, isLast: Bool = false) {
        self.capsule = capsule
        self.isLast = isLast
    }
    
    private var sealedDurationText: String {
        guard let openedDate = capsule.openedAt else { return "Opened" }
        let components = Calendar.current.dateComponents([.day, .month, .year], from: capsule.createdAt, to: openedDate)
        
        if let year = components.year, year > 0 {
            return "Sealed for \(year) \(year == 1 ? "year" : "years")"
        } else if let month = components.month, month > 0 {
            return "Sealed for \(month) \(month == 1 ? "month" : "months")"
        } else if let day = components.day, day > 0 {
            return "Sealed for \(day) \(day == 1 ? "day" : "days")"
        } else {
            return "Sealed recently"
        }
    }
    
    public var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Timeline Rail
            VStack(spacing: 0) {
                Circle()
                    .fill(Theme.Colors.emerald)
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle()
                            .strokeBorder(Theme.Colors.adaptiveBackground, lineWidth: 2)
                    )
                
                if !isLast {
                    Rectangle()
                        .fill(Theme.Colors.adaptiveBorder)
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 16)
            
            // Memory Card
            VStack(alignment: .leading, spacing: 10) {
                // Header: Unsealed Date & Time Traveled
                HStack {
                    Text(capsule.openedAt?.formatted(date: .long, time: .omitted) ?? "Unsealed")
                        .font(Theme.Typography.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.Colors.emerald)
                    
                    Spacer()
                    
                    Text(sealedDurationText)
                        .font(Theme.Typography.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(capsule.title)
                    .font(Theme.Typography.serifTitle)
                    .foregroundColor(.primary)
                
                Text(capsule.message)
                    .font(Theme.Typography.serifBody)
                    .foregroundColor(.secondary)
                    .lineLimit(4)
                
                if let imageData = capsule.localImageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                
                HStack {
                    Image(systemName: "seal.fill")
                        .font(.system(size: 11))
                        .foregroundColor(Theme.Colors.terracotta)
                    Text("Original seal: \(capsule.sealType.displayName)")
                        .font(Theme.Typography.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 2)
            }
            .padding(16)
            .cardSurface(cornerRadius: 16)
            .padding(.bottom, 20)
        }
    }
}

