import SwiftUI

/// Interactive selector for physical sealing metaphors.
public struct SealPickerView: View {
    @Binding var selectedSeal: SealType
    
    public init(selectedSeal: Binding<SealType>) {
        self._selectedSeal = selectedSeal
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Physical Seal Metaphor", systemImage: "seal")
                .font(Theme.Typography.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                ForEach(SealType.allCases) { seal in
                    Button {
                        HapticFeedback.shared.selectionChanged()
                        withAnimation(Theme.AnimationCurve.gestureSpring) {
                            selectedSeal = seal
                        }
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: seal.iconName)
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(selectedSeal == seal ? .white : .primary)
                            
                            Text(seal.displayName)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(selectedSeal == seal ? .white : .secondary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(selectedSeal == seal ? Theme.Colors.terracotta : Theme.Colors.adaptiveCard)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(selectedSeal == seal ? Color.clear : Theme.Colors.adaptiveBorder, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

