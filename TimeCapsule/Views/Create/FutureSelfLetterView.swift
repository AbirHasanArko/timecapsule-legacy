import SwiftUI
import PhotosUI
import UIKit

/// Dedicated, serene writing studio specifically tailored for letters addressed to your future self.
public struct FutureSelfLetterView: View {
    @StateObject private var viewModel: CreateCapsuleViewModel
    let userId: String
    let onSaved: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isMessageFocused: Bool
    
    public init(
        userId: String,
        repository: CapsuleRepositoryProtocol = MockCapsuleRepository(),
        onSaved: @escaping () -> Void
    ) {
        self.userId = userId
        self.onSaved = onSaved
        let vm = CreateCapsuleViewModel(repository: repository)
        vm.selectedCategoryId = "future_self"
        vm.selectedSealType = .waxSeal
        self._viewModel = StateObject(wrappedValue: vm)
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Quote
                    VStack(spacing: 8) {
                        Text("Dear Future Me")
                            .font(Theme.Typography.serifLargeTitle)
                            .foregroundColor(.primary)
                        
                        Text("Capture your present reality. Give your future self a gift of memory.")
                            .font(Theme.Typography.serifQuote)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .padding(.top, 12)
                    
                    // Title Input
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Subject / Letter Title")
                            .font(Theme.Typography.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        TextField("e.g. Where I am right now, at 24", text: $viewModel.title)
                            .font(Theme.Typography.serifTitle)
                            .padding(14)
                            .cardSurface(cornerRadius: 14)
                    }
                    .padding(.horizontal, 24)
                    
                    // Prompt Carousel (Filter only future_self prompts)
                    let futurePrompts = viewModel.prompts.filter { $0.categoryId == "future_self" }
                    if !futurePrompts.isEmpty {
                        PromptCarouselView(prompts: futurePrompts) { prompt in
                            viewModel.applyPrompt(prompt)
                        }
                    }
                    
                    // Letter Body (Parchment Styled)
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Your Letter")
                                .font(Theme.Typography.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(viewModel.message.count) characters")
                                .font(Theme.Typography.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        ZStack(alignment: .topLeading) {
                            if viewModel.message.isEmpty {
                                Text("Speak honestly. How do you feel today? What do you hope has changed when you read this?")
                                    .font(Theme.Typography.serifBody)
                                    .foregroundColor(.secondary.opacity(0.6))
                                    .padding(.top, 16)
                                    .padding(.leading, 18)
                            }
                            
                            TextEditor(text: $viewModel.message)
                                .font(Theme.Typography.serifBody)
                                .lineSpacing(7)
                                .focused($isMessageFocused)
                                .frame(minHeight: 220)
                                .padding(14)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                        }
                        .cardSurface(cornerRadius: 16)
                    }
                    .padding(.horizontal, 24)
                    
                    // Photo Attachment
                    photoSection
                        .padding(.horizontal, 24)
                    
                    // Time Lock Presets
                    timeLockSection
                        .padding(.horizontal, 24)
                    
                    // Seal Action Button
                    Button {
                        Task {
                            let success = await viewModel.sealCapsule(userId: userId)
                            if success {
                                onSaved()
                                dismiss()
                            }
                        }
                    } label: {
                        HStack(spacing: 10) {
                            if viewModel.isSealing {
                                ProgressView().tint(.white)
                            } else {
                                Image(systemName: "seal.fill")
                            }
                            Text(viewModel.isSealing ? "Applying Wax Seal..." : "Seal Letter With Wax")
                        }
                    }
                    .tactilePrimary()
                    .disabled(!viewModel.canSeal || viewModel.isSealing)
                    .opacity(viewModel.canSeal ? 1.0 : 0.5)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 36)
                }
                .padding(.vertical, 16)
            }
            .background(Theme.Colors.adaptiveBackground.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Attach a Snapshot From Today")
                .font(Theme.Typography.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            if let imageData = viewModel.attachedImageData, let uiImage = UIImage(data: imageData) {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    
                    Button {
                        viewModel.removeAttachedPhoto()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .shadow(radius: 4)
                            .padding(10)
                    }
                }
            } else {
                PhotosPicker(selection: $viewModel.selectedPhotoItem, matching: .images) {
                    HStack(spacing: 8) {
                        Image(systemName: "camera")
                            .foregroundColor(Theme.Colors.terracotta)
                        Text("Add a Photo")
                            .font(Theme.Typography.subheadline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .cardSurface(cornerRadius: 12)
                }
                .onChange(of: viewModel.selectedPhotoItem) { _, newItem in
                    Task { await viewModel.handlePhotoSelection(newItem) }
                }
            }
        }
    }
    
    private var timeLockSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("When Should Future You Read This?")
                .font(Theme.Typography.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            HStack(spacing: 8) {
                ForEach([UnlockDatePreset.sixMonths, .oneYear, .fiveYears]) { preset in
                    let isSelected = viewModel.selectedPreset == preset
                    Button {
                        HapticFeedback.shared.selectionChanged()
                        viewModel.selectedPreset = preset
                    } label: {
                        Text(preset.rawValue)
                            .font(Theme.Typography.caption)
                            .fontWeight(.medium)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(isSelected ? Theme.Colors.waxCrimson : Theme.Colors.adaptiveCard)
                            )
                            .foregroundColor(isSelected ? .white : .primary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

