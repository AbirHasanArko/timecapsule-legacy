import SwiftUI

/// Root view routing between Authentication and the main Capsule Dashboard.
public struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var dashboardViewModel = DashboardViewModel()
    
    public init() {}
    
    public var body: some View {
        Group {
            if authViewModel.isAuthenticated, let user = authViewModel.currentUser {
                DashboardView(
                    viewModel: dashboardViewModel,
                    userId: user.id
                ) {
                    authViewModel.signOut()
                }
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.98)),
                    removal: .opacity
                ))
            } else {
                LoginView(viewModel: authViewModel)
                    .transition(.opacity)
            }
        }
        .animation(Theme.AnimationCurve.gestureSpring, value: authViewModel.isAuthenticated)
    }
}

