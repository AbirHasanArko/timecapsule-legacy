import SwiftUI
import PhotosUI

/// Full-screen capsule creation studio adhering to Apple Design and high craft standards.
public struct CreateCapsuleView: View {
    @ObservedObject var viewModel: CreateCapsuleViewModel
    let userId: String
    let onSaved: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isMessageFocused: Bool
    
    public init(
        viewModel: CreateCapsuleViewModel,
        userId: String,
        onSaved: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.userId = userId
        self.onSaved = onSaved
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Category Picker Pills
                    categorySelector
                    
                    // Title Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Capsule Title")
                            .font(Theme.Typography.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        TextField("e.g. Letter to My 2027 Self", text: $viewModel.title)
                            .font(Theme.Typography.serifTitle)
                            .padding(14)
                            .cardSurface(cornerRadius: 14)
                    }
                    .padding(.horizontal, 24)
                    
                    // Inspirational Prompts Carousel
                    PromptCarouselView(prompts: viewModel.prompts) { prompt in
                        viewModel.applyPrompt(prompt)
                    }
                    
                    // Message / Letter Body
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Letter / Memory")
                                .font(Theme.Typography.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(viewModel.message.count) chars")
                                .font(Theme.Typography.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        ZStack(alignment: .topLeading) {
                            if viewModel.message.isEmpty {
                                Text("Write freely to your future self... What are you thinking, hoping, or learning today?")
                                    .font(Theme.Typography.serifBody)
                                    .foregroundColor(.secondary.opacity(0.6))
                                    .padding(.top, 16)
                                    .padding(.leading, 18)
                            }
                            
                            TextEditor(text: $viewModel.message)
                                .font(Theme.Typography.serifBody)
                                .lineSpacing(6)
                                .focused($isMessageFocused)
                                .frame(minHeight: 180)
                                .padding(12)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                        }
                        .cardSurface(cornerRadius: 16)
                    }
                    .padding(.horizontal, 24)
                    
                    // Photo Attachment Section
                    photoAttachmentSection
                        .padding(.horizontal, 24)
                    
                    // Time Lock Section
                    timeLockSection
                        .padding(.horizontal, 24)
                    
                    // Seal Type Picker
                    SealPickerView(selectedSeal: $viewModel.selectedSealType)
                        .padding(.horizontal, 24)
                    
                    // Error Notice if any
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(Theme.Typography.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal, 24)
                    }
                    
                    // Seal and Lock Action Button
                    sealActionButton
                        .padding(.horizontal, 24)
                        .padding(.bottom, 36)
                }
                .padding(.vertical, 16)
            }
            .background(Theme.Colors.adaptiveBackground.ignoresSafeArea())
            .navigationTitle("New Capsule")
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
    
    // MARK: - Category Selector
    private var categorySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(viewModel.categories) { category in
                    let isSelected = viewModel.selectedCategoryId == category.id
                    Button {
                        HapticFeedback.shared.selectionChanged()
                        viewModel.selectedCategoryId = category.id
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: category.icon)
                                .font(.system(size: 13, weight: .semibold))
                            Text(category.name)
                                .font(Theme.Typography.caption)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(isSelected ? category.accentColor : Theme.Colors.adaptiveCard)
                        )
                        .foregroundColor(isSelected ? .white : .primary)
                        .overlay(
                            Capsule()
                                .strokeBorder(isSelected ? Color.clear : Theme.Colors.adaptiveBorder, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Photo Attachment
    private var photoAttachmentSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Photo Memory (Optional)", systemImage: "photo")
                .font(Theme.Typography.subheadline)
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
                PhotosPicker(
                    selection: $viewModel.selectedPhotoItem,
                    matching: .images
                ) {
                    HStack(spacing: 10) {
                        Image(systemName: "camera.fill")
                            .foregroundColor(Theme.Colors.terracotta)
                        Text("Add a Photo From Today")
                            .font(Theme.Typography.headline)
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .cardSurface(cornerRadius: 14)
                }
                .onChange(of: viewModel.selectedPhotoItem) { _, newItem in
                    Task {
                        await viewModel.handlePhotoSelection(newItem)
                    }
                }
            }
        }
    }
    
    // MARK: - Time Lock Section
    private var timeLockSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Time Lock Duration", systemImage: "hourglass")
                .font(Theme.Typography.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            // Preset Pills
            HStack(spacing: 8) {
                ForEach(UnlockDatePreset.allCases) { preset in
                    let isSelected = viewModel.selectedPreset == preset
                    Button {
                        HapticFeedback.shared.selectionChanged()
                        viewModel.selectedPreset = preset
                    } label: {
                        Text(preset.rawValue)
                            .font(Theme.Typography.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(isSelected ? Theme.Colors.antiqueGold : Theme.Colors.adaptiveCard)
                            )
                            .foregroundColor(isSelected ? .white : .primary)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .strokeBorder(isSelected ? Color.clear : Theme.Colors.adaptiveBorder, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // Target date readout
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .foregroundColor(Theme.Colors.antiqueGold)
                Text("Will unlock on: ")
                    .foregroundColor(.secondary)
                Text(viewModel.calculatedUnlockDate.formatted(date: .long, time: .shortened))
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            .font(Theme.Typography.caption)
            .padding(.top, 4)
            
            // Custom Date Picker if selected
            if viewModel.selectedPreset == .custom {
                DatePicker(
                    "Select Exact Unlock Date",
                    selection: $viewModel.customDate,
                    in: Date()...,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.compact)
                .padding(12)
                .cardSurface(cornerRadius: 12)
            }
        }
    }
    
    // MARK: - Action Button
    private var sealActionButton: some View {
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
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "lock.shield.fill")
                }
                Text(viewModel.isSealing ? "Sealing Capsule..." : "Seal & Lock Time Capsule")
            }
        }
        .tactilePrimary()
        .disabled(!viewModel.canSeal || viewModel.isSealing)
        .opacity(viewModel.canSeal ? 1.0 : 0.5)
    }
}

