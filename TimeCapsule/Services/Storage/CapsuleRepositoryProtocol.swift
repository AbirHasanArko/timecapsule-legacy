import Foundation

/// Protocol defining storage operations for TimeCapsules.
public protocol CapsuleRepositoryProtocol: Sendable {
    func fetchCapsules(for userId: String) async throws -> [Capsule]
    func saveCapsule(_ capsule: Capsule) async throws
    func updateCapsule(_ capsule: Capsule) async throws
    func markCapsuleAsOpened(capsuleId: String, openedAt: Date) async throws
    func deleteCapsule(capsuleId: String) async throws
}

