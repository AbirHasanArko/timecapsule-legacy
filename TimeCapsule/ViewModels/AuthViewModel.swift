import SwiftUI
import Combine

/// ViewModel managing user authentication, registration, and guest access.
@MainActor
public final class AuthViewModel: ObservableObject {
    @Published public var email: String = ""
    @Published public var password: String = ""
    @Published public var displayName: String = ""
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    @Published public var isAuthenticated: Bool = false
    @Published public var currentUser: UserProfile? = nil
    
    private let authService: AuthServiceProtocol
    
    public init(authService: AuthServiceProtocol = MockAuthService(autoLogin: true)) {
        self.authService = authService
        if let user = authService.currentUser {
            self.currentUser = user
            self.isAuthenticated = true
        }
    }
    
    public var isValidForm: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        email.contains("@") &&
        password.count >= 6
    }
    
    public func signIn() async {
        guard isValidForm else {
            errorMessage = "Please enter a valid email and at least 6 characters for the password."
            HapticFeedback.shared.error()
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let user = try await authService.signIn(email: email, password: password)
            self.currentUser = user
            self.isAuthenticated = true
            HapticFeedback.shared.success()
        } catch {
            self.errorMessage = error.localizedDescription
            HapticFeedback.shared.error()
        }
        
        isLoading = false
    }
    
    public func signUp() async {
        guard isValidForm else {
            errorMessage = "Please enter a valid email and at least 6 characters for the password."
            HapticFeedback.shared.error()
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let user = try await authService.signUp(
                email: email,
                password: password,
                displayName: displayName.isEmpty ? nil : displayName
            )
            self.currentUser = user
            self.isAuthenticated = true
            HapticFeedback.shared.success()
        } catch {
            self.errorMessage = error.localizedDescription
            HapticFeedback.shared.error()
        }
        
        isLoading = false
    }
    
    public func continueAsGuest() {
        let guest = UserProfile(
            id: "demo_user",
            email: "guest@timecapsule.app",
            displayName: "Traveler"
        )
        self.currentUser = guest
        self.isAuthenticated = true
        HapticFeedback.shared.light()
    }
    
    public func signOut() {
        do {
            try authService.signOut()
            self.currentUser = nil
            self.isAuthenticated = false
            self.email = ""
            self.password = ""
            HapticFeedback.shared.light()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}

