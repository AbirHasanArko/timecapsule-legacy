import Foundation

#if canImport(FirebaseStorage)
import FirebaseStorage

/// Production Firebase Storage service for uploading photos attached to capsules.
public final class FirebaseStorageService: @unchecked Sendable {
    public static let shared = FirebaseStorageService()
    private let storage = Storage.storage()
    
    private init() {}
    
    public func uploadPhoto(data: Data, capsuleId: String) async throws -> URL {
        let storageRef = storage.reference().child("capsule_photos/\(capsuleId).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        _ = try await storageRef.putDataAsync(data, metadata: metadata)
        return try await storageRef.downloadURL()
    }
}
#else
public final class FirebaseStorageService: @unchecked Sendable {
    public static let shared = FirebaseStorageService()
    private init() {}
    
    public func uploadPhoto(data: Data, capsuleId: String) async throws -> URL {
        // Mock fallback local file URL
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(capsuleId).jpg")
        try data.write(to: tempURL)
        return tempURL
    }
}
#endif

