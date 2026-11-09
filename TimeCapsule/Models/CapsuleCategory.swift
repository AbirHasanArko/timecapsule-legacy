import SwiftUI

/// Category defining the theme and context of a time capsule.
public struct CapsuleCategory: Identifiable, Codable, Sendable, Hashable {
    public let id: String
    public let name: String
    public let description: String
    public let icon: String
    public let colorHex: String
    
    public init(
        id: String,
        name: String,
        description: String,
        icon: String,
        colorHex: String
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
        self.colorHex = colorHex
    }
    
    public var accentColor: Color {
        Color(hex: colorHex)
    }
}

// MARK: - Color Hex Initializer
public extension Color {
    init(hex: String) {
        let cleanHex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleanHex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch cleanHex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 128, 128, 128)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

