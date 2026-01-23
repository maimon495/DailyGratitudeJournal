import SwiftUI

enum JournalFont: String, CaseIterable, Identifiable {
    case classicSerif = "classic_serif"
    case elegantScript = "elegant_script"
    case modernSans = "modern_sans"
    case typewriter = "typewriter"
    case casual = "casual"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .classicSerif: return "Classic Serif"
        case .elegantScript: return "Elegant Script"
        case .modernSans: return "Modern Sans"
        case .typewriter: return "Typewriter"
        case .casual: return "Casual"
        }
    }

    var description: String {
        switch self {
        case .classicSerif: return "Traditional, timeless elegance"
        case .elegantScript: return "Flowing, handwritten style"
        case .modernSans: return "Clean and minimal"
        case .typewriter: return "Vintage monospace feel"
        case .casual: return "Friendly and approachable"
        }
    }

    var fontDesign: Font.Design {
        switch self {
        case .classicSerif: return .serif
        case .elegantScript: return .serif
        case .modernSans: return .default
        case .typewriter: return .monospaced
        case .casual: return .rounded
        }
    }

    func font(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        switch self {
        case .classicSerif:
            return .system(size: size, weight: weight, design: .serif)
        case .elegantScript:
            // Use a custom font if available, fallback to italic serif
            if let _ = UIFont(name: "Snell Roundhand", size: size) {
                return .custom("Snell Roundhand", size: size)
            }
            return .system(size: size, weight: weight, design: .serif).italic()
        case .modernSans:
            return .system(size: size, weight: weight, design: .default)
        case .typewriter:
            if let _ = UIFont(name: "American Typewriter", size: size) {
                return .custom("American Typewriter", size: size)
            }
            return .system(size: size, weight: weight, design: .monospaced)
        case .casual:
            return .system(size: size, weight: weight, design: .rounded)
        }
    }

    var bodyFont: Font {
        font(size: 18)
    }

    var headlineFont: Font {
        font(size: 20, weight: .medium)
    }

    var titleFont: Font {
        font(size: 28, weight: .medium)
    }

    var captionFont: Font {
        font(size: 14)
    }

    // Line spacing varies by font for optimal readability
    var lineSpacing: CGFloat {
        switch self {
        case .classicSerif: return 8
        case .elegantScript: return 10
        case .modernSans: return 6
        case .typewriter: return 8
        case .casual: return 7
        }
    }
}
