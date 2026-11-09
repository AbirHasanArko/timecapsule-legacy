import Foundation

#if canImport(FirebaseAuth)
import FirebaseAuth

/// Production Firebase Authentication Service
public final class FirebaseAuthService: AuthServiceProtocol, @unchecked Sendable {
    public init() {}
    
    public var currentUser: UserProfile? {
        guard let user = Auth.auth().currentUser else { return nil }
        return UserProfile(
            id: user.uid,
            email: user.email ?? "",
            displayName: user.displayName
        )
    }
    
    public func signIn(email: String, password: String) async throws -> UserProfile {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return UserProfile(
            id: result.user.uid,
            email: result.user.email ?? email,
            displayName: result.user.displayName
        )
    }
    
    public func signUp(email: String, password: String, displayName: String?) async throws -> UserProfile {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        if let displayName = displayName {
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = displayName
            try await changeRequest.commitChanges()
        }
        return UserProfile(
            id: result.user.uid,
            email: result.user.email ?? email,
            displayName: displayName
        )
    }
    
    public func signOut() throws {
        try Auth.auth().signOut()
    }
}
#else
/// Fallback wrapper when FirebaseAuth SDK is not yet linked in Xcode SPM.
public final class FirebaseAuthService: AuthServiceProtocol, @unchecked Sendable {
    public var currentUser: UserProfile? = nil
    
    public init() {}
    
    public func signIn(email: String, password: String) async throws -> UserProfile {
        throw NSError(
            domain: "FirebaseAuthService",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "FirebaseAuth SDK not linked. Please add FirebaseAuth via Swift Package Manager."]
        )
    }
    
    public func signUp(email: String, password: String, displayName: String?) async throws -> UserProfile {
        throw NSError(
            domain: "FirebaseAuthService",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "FirebaseAuth SDK not linked. Please add FirebaseAuth via Swift Package Manager."]
        )
    }
    
    public func signOut() throws {}
}
#endif

