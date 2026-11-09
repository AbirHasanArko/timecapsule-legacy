import Foundation

/// Mock authentication service allowing rapid testing and guest exploration
/// without network dependencies.
public final class MockAuthService: AuthServiceProtocol, @unchecked Sendable {
    public private(set) var currentUser: UserProfile?
    
    public init(autoLogin: Bool = true) {
        if autoLogin {
            self.currentUser = UserProfile(
                id: "demo_user",
                email: "traveler@timecapsule.app",
                displayName: "Time Traveler"
            )
        }
    }
    
    public func signIn(email: String, password: String) async throws -> UserProfile {
        // Simulated network latency
        try await Task.sleep(nanoseconds: 300_000_000)
        
        let user = UserProfile(
            id: UUID().uuidString,
            email: email,
            displayName: email.components(separatedBy: "@").first?.capitalized ?? "Traveler"
        )
        self.currentUser = user
        return user
    }
    
    public func signUp(email: String, password: String, displayName: String?) async throws -> UserProfile {
        try await Task.sleep(nanoseconds: 300_000_000)
        
        let user = UserProfile(
            id: UUID().uuidString,
            email: email,
            displayName: displayName ?? "Traveler"
        )
        self.currentUser = user
        return user
    }
    
    public func signOut() throws {
        self.currentUser = nil
    }
}

