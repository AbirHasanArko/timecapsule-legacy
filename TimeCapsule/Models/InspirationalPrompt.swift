import Foundation

/// Prompt used to inspire letter writing and thoughtful capsule creation.
public struct InspirationalPrompt: Identifiable, Codable, Sendable, Hashable {
    public let id: String
    public let categoryId: String
    public let text: String
    public let author: String
    
    public init(id: String, categoryId: String, text: String, author: String) {
        self.id = id
        self.categoryId = categoryId
        self.text = text
        self.author = author
    }
}

