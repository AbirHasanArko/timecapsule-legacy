import Foundation

/// User session representation.
public struct UserProfile: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public let email: String
    public let displayName: String?
    
    public init(id: String, email: String, displayName: String? = nil) {
        self.id = id
        self.email = email
        self.displayName = displayName
    }
}

/// Protocol abstracting Firebase Authentication.
public protocol AuthServiceProtocol: Sendable {
    var currentUser: UserProfile? { get }
    func signIn(email: String, password: String) async throws -> UserProfile
    func signUp(email: String, password: String, displayName: String?) async throws -> UserProfile
    func signOut() throws
}

