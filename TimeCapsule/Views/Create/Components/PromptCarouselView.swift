import SwiftUI

/// Horizontal carousel displaying inspirational prompts from bundled prompts.json.
public struct PromptCarouselView: View {
    let prompts: [InspirationalPrompt]
    let onSelectPrompt: (InspirationalPrompt) -> Void
    
    public init(prompts: [InspirationalPrompt], onSelectPrompt: @escaping (InspirationalPrompt) -> Void) {
        self.prompts = prompts
        self.onSelectPrompt = onSelectPrompt
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Inspirational Prompts", systemImage: "sparkles")
                    .font(Theme.Typography.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Tap to add")
                    .font(Theme.Typography.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 24)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(prompts) { prompt in
                        Button {
                            onSelectPrompt(prompt)
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(prompt.text)
                                    .font(Theme.Typography.serifQuote)
                                    .foregroundColor(.primary)
                                    .lineLimit(3)
                                    .multilineTextAlignment(.leading)
                                
                                Text("— \(prompt.author)")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(Theme.Colors.terracotta)
                            }
                            .padding(14)
                            .frame(width: 220, height: 110, alignment: .topLeading)
                            .cardSurface(cornerRadius: 14)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

