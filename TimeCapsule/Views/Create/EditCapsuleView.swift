import SwiftUI
import PhotosUI
import UIKit

/// Editing view allowing updates to a sealed capsule strictly within its timed grace window.
public struct EditCapsuleView: View {
    @Environment(\.dismiss) private var dismiss
    
    let originalCapsule: Capsule
    let onSaved: (Capsule) -> Void
    
    @State private var title: String
    @State private var message: String
    @State private var selectedCategoryId: String
    @State private var unlockDate: Date
    @State private var selectedSealType: SealType
    @State private var attachedImageData: Data?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var referenceDate: Date = Date()
    @State private var errorMessage: String?
    @State private var isSaving: Bool = false
    
    private let categories: [CapsuleCategory]
    private let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    public init(
        capsule: Capsule,
        categories: [CapsuleCategory] = PromptService.shared.loadCategories(),
        onSaved: @escaping (Capsule) -> Void
    ) {
        self.originalCapsule = capsule
        self.categories = categories
        self.onSaved = onSaved
        
        self._title = State(initialValue: capsule.title)
        self._message = State(initialValue: capsule.message)
        self._selectedCategoryId = State(initialValue: capsule.categoryId)
        self._unlockDate = State(initialValue: capsule.unlockDate)
        self._selectedSealType = State(initialValue: capsule.sealType)
        self._attachedImageData = State(initialValue: capsule.localImageData)
    }
    
    private var isGraceWindowActive: Bool {
        originalCapsule.canBeUpdated(at: referenceDate)
    }
    
    private var remainingGraceString: String {
        originalCapsule.formattedRemainingGraceTime(at: referenceDate) ?? "00m 00s"
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Grace Window Banner
                    graceWindowBanner
                        .padding(.horizontal, 24)
                        .padding(.top, 12)
                    
                    // Title Input
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Capsule Title")
                            .font(Theme.Typography.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        TextField("Title", text: $title)
                            .font(Theme.Typography.serifTitle)
                            .padding(14)
                            .cardSurface(cornerRadius: 14)
                    }
                    .padding(.horizontal, 24)
                    
                    // Message / Body
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Message Body")
                            .font(Theme.Typography.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: $message)
                            .font(Theme.Typography.serifBody)
                            .lineSpacing(6)
                            .frame(minHeight: 180)
                            .padding(12)
                            .cardSurface(cornerRadius: 14)
                    }
                    .padding(.horizontal, 24)
                    
                    // Photo Attachment
                    photoAttachmentSection
                        .padding(.horizontal, 24)
                    
                    // Unlock Date Adjustment
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Target Unlock Date", systemImage: "calendar.badge.clock")
                            .font(Theme.Typography.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        DatePicker(
                            "Unlock Date",
                            selection: $unlockDate,
                            in: Date()...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.compact)
                        .padding(12)
                        .cardSurface(cornerRadius: 12)
                    }
                    .padding(.horizontal, 24)
                    
                    // Seal Picker
                    SealPickerView(selectedSeal: $selectedSealType)
                        .padding(.horizontal, 24)
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(Theme.Typography.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal, 24)
                    }
                    
                    // Save Button
                    Button {
                        saveChanges()
                    } label: {
                        HStack {
                            if isSaving {
                                ProgressView().tint(.white)
                            } else {
                                Image(systemName: "checkmark.seal.fill")
                                Text("Save Modifications")
                            }
                        }
                    }
                    .tactilePrimary()
                    .disabled(!isGraceWindowActive || isSaving || title.isEmpty || message.isEmpty)
                    .opacity(isGraceWindowActive ? 1.0 : 0.4)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 36)
                }
            }
            .background(Theme.Colors.adaptiveBackground.ignoresSafeArea())
            .navigationTitle("Edit Capsule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
            }
            .onReceive(timer) { newDate in
                referenceDate = newDate
            }
        }
    }
    
    // MARK: - Grace Window Banner
    private var graceWindowBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: isGraceWindowActive ? "clock.badge.checkmark" : "lock.fill")
                .font(.system(size: 20))
                .foregroundColor(isGraceWindowActive ? Theme.Colors.terracotta : .secondary)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(isGraceWindowActive ? "Timed Modification Window Active" : "Modification Window Closed")
                    .font(Theme.Typography.caption)
                    .fontWeight(.bold)
                    .foregroundColor(isGraceWindowActive ? Theme.Colors.terracotta : .secondary)
                
                if isGraceWindowActive {
                    Text("\(remainingGraceString) left to adjust content before permanent seal")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.secondary)
                } else {
                    Text("This capsule is now permanently locked in time.")
                        .font(Theme.Typography.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(isGraceWindowActive ? Theme.Colors.terracotta.opacity(0.1) : Color.secondary.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(isGraceWindowActive ? Theme.Colors.terracotta.opacity(0.25) : Theme.Colors.adaptiveBorder, lineWidth: 1)
        )
    }
    
    // MARK: - Photo Section
    private var photoAttachmentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Attached Photo")
                .font(Theme.Typography.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            if let imageData = attachedImageData, let uiImage = UIImage(data: imageData) {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    
                    Button {
                        withAnimation {
                            attachedImageData = nil
                            selectedPhotoItem = nil
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .shadow(radius: 3)
                            .padding(8)
                    }
                }
            } else {
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    HStack(spacing: 8) {
                        Image(systemName: "photo")
                        Text("Add or Replace Photo")
                    }
                    .font(Theme.Typography.subheadline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .cardSurface(cornerRadius: 12)
                }
                .onChange(of: selectedPhotoItem) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            attachedImageData = data
                        }
                    }
                }
            }
        }
    }
    
    private func saveChanges() {
        guard isGraceWindowActive else {
            errorMessage = "The modification window has expired. Capsule cannot be edited."
            HapticFeedback.shared.error()
            return
        }
        
        isSaving = true
        var updated = originalCapsule
        updated.title = title.trimmingCharacters(in: .whitespaces)
        updated.message = message.trimmingCharacters(in: .whitespaces)
        updated.categoryId = selectedCategoryId
        updated.unlockDate = unlockDate
        updated.sealType = selectedSealType
        updated.localImageData = attachedImageData
        
        HapticFeedback.shared.success()
        onSaved(updated)
        dismiss()
    }
}

