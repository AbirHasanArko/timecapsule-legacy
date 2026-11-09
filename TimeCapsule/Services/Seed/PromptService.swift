import Foundation

/// Service responsible for loading bundled categories and inspirational prompts
/// with baked-in fallback data to guarantee resilience even without bundle linkage.
public final class PromptService: Sendable {
    public static let shared = PromptService()
    
    public init() {}
    
    private var resourceBundle: Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return Bundle.main
        #endif
    }
    
    public func loadCategories() -> [CapsuleCategory] {
        let bundle = resourceBundle
        let url = bundle.url(forResource: "categories", withExtension: "json") ?? Bundle.main.url(forResource: "categories", withExtension: "json")
        if let url = url,
           let data = try? Data(contentsOf: url),
           let categories = try? JSONDecoder().decode([CapsuleCategory].self, from: data) {
            return categories
        }

        
        // Fallback default categories
        return [
            CapsuleCategory(
                id: "future_self",
                name: "Letter to Future Self",
                description: "Heartfelt messages, hopes, and grounding thoughts for who you will become.",
                icon: "envelope.badge.shield.half.filled",
                colorHex: "#D97736"
            ),
            CapsuleCategory(
                id: "predictions",
                name: "Bold Predictions",
                description: "Guesses about the world, technology, society, and your personal milestones.",
                icon: "sparkles",
                colorHex: "#4A6FA5"
            ),
            CapsuleCategory(
                id: "reflections",
                name: "Life Reflections",
                description: "Snapshots of your current mindset, philosophy, and daily rituals.",
                icon: "sun.haze.fill",
                colorHex: "#B8860B"
            ),
            CapsuleCategory(
                id: "gratitude",
                name: "Pockets of Gratitude",
                description: "Things, people, and quiet moments you never want to take for granted.",
                icon: "heart.fill",
                colorHex: "#C05646"
            ),
            CapsuleCategory(
                id: "secrets",
                name: "Confidential Vault",
                description: "Private confessions and raw memories sealed under ironclad lock.",
                icon: "lock.shield.fill",
                colorHex: "#5A626A"
            )
        ]
    }
    
    public func loadPrompts() -> [InspirationalPrompt] {
        let bundle = resourceBundle
        let url = bundle.url(forResource: "prompts", withExtension: "json") ?? Bundle.main.url(forResource: "prompts", withExtension: "json")
        if let url = url,
           let data = try? Data(contentsOf: url),
           let prompts = try? JSONDecoder().decode([InspirationalPrompt].self, from: data) {
            return prompts
        }
        
        // Fallback default prompts
        return [
            InspirationalPrompt(
                id: "prompt_1",
                categoryId: "future_self",
                text: "What is one belief you hold dear today that you wonder if you will outgrow?",
                author: "Quiet Reflection"
            ),
            InspirationalPrompt(
                id: "prompt_2",
                categoryId: "future_self",
                text: "Describe the ordinary sights, sounds, and smells surrounding you right at this moment.",
                author: "Sensory Snapshot"
            ),
            InspirationalPrompt(
                id: "prompt_3",
                categoryId: "future_self",
                text: "What is something heavy you are carrying today that you hope is solved when this opens?",
                author: "Hopes & Release"
            ),
            InspirationalPrompt(
                id: "prompt_4",
                categoryId: "predictions",
                text: "Where do you think you will be living, working, and spending your mornings?",
                author: "Future Horizon"
            ),
            InspirationalPrompt(
                id: "prompt_5",
                categoryId: "reflections",
                text: "What decision took real courage recently, and how did it change your perspective?",
                author: "Courage Log"
            ),
            InspirationalPrompt(
                id: "prompt_6",
                categoryId: "gratitude",
                text: "Who is someone you are deeply grateful for right now, and what unspoken gift have they given you?",
                author: "Gratitude Chronicle"
            ),
            InspirationalPrompt(
                id: "prompt_7",
                categoryId: "secrets",
                text: "What is one truth you know about yourself that you are hesitant to admit out loud?",
                author: "Inner Truth"
            )
        ]
    }
}

