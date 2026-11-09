import SwiftUI

/// Main dashboard displaying categorized capsules, live countdowns, and quick creation access.
public struct DashboardView: View {
    @ObservedObject var viewModel: DashboardViewModel
    let userId: String
    let onSignOut: () -> Void
    
    @State private var isShowingCreateSheet: Bool = false
    @State private var isShowingFutureSelfLetter: Bool = false
    @State private var isShowingTimeline: Bool = false
    @State private var editingCapsule: Capsule? = nil
    
    public init(
        viewModel: DashboardViewModel,
        userId: String,
        onSignOut: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.userId = userId
        self.onSignOut = onSignOut
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with App Title & Filter Pills
                headerSection
                
                // Capsules Scroll List
                if viewModel.isLoading && viewModel.capsules.isEmpty {
                    Spacer()
                    ProgressView("Retrieving Sealed Capsules...")
                        .font(Theme.Typography.caption)
                    Spacer()
                } else if viewModel.filteredCapsules.isEmpty {
                    emptyStateView
                } else {
                    capsuleListView
                }
            }
            .background(Theme.Colors.adaptiveBackground.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        isShowingTimeline = true
                    } label: {
                        Label("Timeline", systemImage: "clock.arrow.circlepath")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Theme.Colors.terracotta)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 14) {
                        Button {
                            isShowingFutureSelfLetter = true
                        } label: {
                            Image(systemName: "envelope.badge.shield.half.filled")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Theme.Colors.terracotta)
                        }
                        .help("Write Letter to Future Self")
                        
                        Menu {
                            Button {
                                isShowingFutureSelfLetter = true
                            } label: {
                                Label("Letter to Future Self", systemImage: "envelope.badge.shield.half.filled")
                            }
                            
                            Button {
                                Task {
                                    await NotificationManager.shared.sendTestNotification(delaySeconds: 5)
                                }
                            } label: {
                                Label("Test Notification (5s)", systemImage: "bell.badge")
                            }
                            
                            Divider()
                            
                            Button(role: .destructive) {
                                onSignOut()
                            } label: {
                                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                            }
                        } label: {
                            Image(systemName: "person.crop.circle")
                                .font(.system(size: 18))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .sheet(isPresented: $isShowingCreateSheet) {
                CreateCapsuleView(
                    viewModel: CreateCapsuleViewModel(),
                    userId: userId
                ) {
                    Task {
                        await viewModel.loadCapsules(for: userId)
                    }
                }
            }
            .sheet(isPresented: $isShowingFutureSelfLetter) {
                FutureSelfLetterView(userId: userId) {
                    Task {
                        await viewModel.loadCapsules(for: userId)
                    }
                }
            }
            .sheet(isPresented: $isShowingTimeline) {
                TimelineView(capsules: viewModel.capsules.filter { $0.isOpened })
            }
            .sheet(item: $editingCapsule) { capsuleToEdit in
                EditCapsuleView(capsule: capsuleToEdit) { updated in
                    Task {
                        await viewModel.updateCapsule(updated)
                    }
                }
            }
            .overlay(alignment: .bottomTrailing) {
                floatingCreateButton
            }
            .task {
                await viewModel.loadCapsules(for: userId)
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("TimeCapsule")
                        .font(Theme.Typography.serifLargeTitle)
                        .foregroundColor(.primary)
                    Text("Sealed memories & future letters")
                        .font(Theme.Typography.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            
            // Search field
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search memories, titles, or notes...", text: $viewModel.searchQuery)
                    .font(Theme.Typography.subheadline)
            }
            .padding(10)
            .cardSurface(cornerRadius: 12)
            .padding(.horizontal, 24)
            
            // Filter Pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(CapsuleFilter.allCases) { filter in
                        let isSelected = viewModel.selectedFilter == filter
                        Button {
                            HapticFeedback.shared.selectionChanged()
                            withAnimation(Theme.AnimationCurve.gestureSpring) {
                                viewModel.selectedFilter = filter
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Text(filter.rawValue)
                                    .font(Theme.Typography.caption)
                                    .fontWeight(.semibold)
                                
                                Text("(\(count(for: filter)))")
                                    .font(.system(size: 11, design: .monospaced))
                                    .opacity(0.8)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(
                                Capsule()
                                    .fill(isSelected ? Theme.Colors.terracotta : Theme.Colors.adaptiveCard)
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
            .padding(.bottom, 8)
        }
        .padding(.bottom, 6)
    }
    
    // MARK: - Capsule List
    private var capsuleListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.filteredCapsules) { capsule in
                    NavigationLink {
                        CapsuleDetailView(
                            capsule: capsule,
                            referenceDate: viewModel.referenceDate,
                            onMarkOpened: {
                                Task {
                                    await viewModel.markAsOpened(capsuleId: capsule.id)
                                }
                            },
                            onUpdate: { updated in
                                Task {
                                    await viewModel.updateCapsule(updated)
                                }
                            },
                            onDelete: {
                                Task {
                                    await viewModel.deleteCapsule(capsule)
                                }
                            }
                        )
                    } label: {
                        CapsuleCardView(
                            capsule: capsule,
                            referenceDate: viewModel.referenceDate
                        )
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        if capsule.canBeUpdated(at: viewModel.referenceDate) {
                            Button {
                                editingCapsule = capsule
                            } label: {
                                Label("Edit Capsule (Window Active)", systemImage: "pencil")
                            }
                        }
                        
                        Button(role: .destructive) {
                            Task {
                                await viewModel.deleteCapsule(capsule)
                            }
                        } label: {
                            Label("Delete Capsule", systemImage: "trash")
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 10)
            .padding(.bottom, 100) // Spacing for floating button
        }
        .refreshable {
            await viewModel.loadCapsules(for: userId)
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Theme.Colors.terracotta.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "hourglass.badge.plus")
                    .font(.system(size: 42))
                    .foregroundColor(Theme.Colors.terracotta)
            }
            
            VStack(spacing: 6) {
                Text(emptyStateTitle)
                    .font(Theme.Typography.serifTitle)
                    .foregroundColor(.primary)
                
                Text(emptyStateDescription)
                    .font(Theme.Typography.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 36)
            }
            
            Button {
                isShowingCreateSheet = true
            } label: {
                Label("Seal Your First Capsule", systemImage: "plus")
            }
            .tactilePrimary(cornerRadius: 14)
            .frame(width: 240)
            .padding(.top, 8)
            
            Spacer()
            Spacer()
        }
    }
    
    // MARK: - Floating Create Button
    private var floatingCreateButton: some View {
        Button {
            HapticFeedback.shared.light()
            isShowingCreateSheet = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .bold))
                Text("New Capsule")
                    .font(Theme.Typography.headline)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                Capsule()
                    .fill(Theme.Colors.terracotta)
            )
            .foregroundColor(.white)
            .shadow(color: Theme.Colors.terracotta.opacity(0.4), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
        .padding(.trailing, 24)
        .padding(.bottom, 24)
    }
    
    private func count(for filter: CapsuleFilter) -> Int {
        switch filter {
        case .all: return viewModel.capsules.count
        case .ready: return viewModel.readyCount
        case .locked: return viewModel.lockedCount
        case .opened: return viewModel.openedCount
        }
    }
    
    private var emptyStateTitle: String {
        switch viewModel.selectedFilter {
        case .all: return "No Capsules Yet"
        case .ready: return "No Capsules Ready to Open"
        case .locked: return "No Locked Capsules"
        case .opened: return "No Unsealed Memories Yet"
        }
    }
    
    private var emptyStateDescription: String {
        switch viewModel.selectedFilter {
        case .all:
            return "Write a letter to your future self, predict an outcome, or seal a private memory today."
        case .ready:
            return "When scheduled dates arrive, locked capsules will appear here ready to be unsealed."
        case .locked:
            return "Seal a new memory and choose a future unlock date."
        case .opened:
            return "Capsules that you have unsealed will be permanently preserved here in your timeline."
        }
    }
}

