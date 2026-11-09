import Foundation

#if canImport(FirebaseFirestore)
import FirebaseFirestore

/// Production Firestore repository synchronizing capsules with Cloud Firestore.
public final class FirestoreCapsuleService: CapsuleRepositoryProtocol, @unchecked Sendable {
    private let db = Firestore.firestore()
    private let collectionName = "capsules"
    
    public init() {}
    
    public func fetchCapsules(for userId: String) async throws -> [Capsule] {
        let snapshot = try await db.collection(collectionName)
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        return try snapshot.documents.compactMap { document in
            try document.data(as: Capsule.self)
        }
    }
    
    public func saveCapsule(_ capsule: Capsule) async throws {
        try db.collection(collectionName)
            .document(capsule.id)
            .setData(from: capsule)
    }
    
    public func updateCapsule(_ capsule: Capsule) async throws {
        guard capsule.canBeUpdated() else {
            throw NSError(domain: "FirestoreCapsuleService", code: 403, userInfo: [NSLocalizedDescriptionKey: "Modification window expired."])
        }
        try db.collection(collectionName)
            .document(capsule.id)
            .setData(from: capsule, merge: true)
    }
    
    public func markCapsuleAsOpened(capsuleId: String, openedAt: Date = Date()) async throws {
        try await db.collection(collectionName).document(capsuleId).updateData([
            "isOpened": true,
            "openedAt": Timestamp(date: openedAt)
        ])
    }
    
    public func deleteCapsule(capsuleId: String) async throws {
        try await db.collection(collectionName).document(capsuleId).delete()
    }
}
#else
/// Fallback when FirebaseFirestore is not linked.
public final class FirestoreCapsuleService: CapsuleRepositoryProtocol, @unchecked Sendable {
    public init() {}
    
    public func fetchCapsules(for userId: String) async throws -> [Capsule] {
        throw NSError(
            domain: "FirestoreCapsuleService",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "FirebaseFirestore SDK not linked. Please add FirebaseFirestore via SPM."]
        )
    }
    
    public func saveCapsule(_ capsule: Capsule) async throws {}
    public func updateCapsule(_ capsule: Capsule) async throws {}
    public func markCapsuleAsOpened(capsuleId: String, openedAt: Date) async throws {}
    public func deleteCapsule(capsuleId: String) async throws {}
}
#endif

