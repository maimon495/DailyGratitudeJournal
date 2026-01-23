import SwiftUI

enum InkColor: String, CaseIterable, Codable {
    case emeraldOfChivor = "emerald_of_chivor"
    case stormyGrey = "stormy_grey"
    case rougeHematite = "rouge_hematite"
    case bleuPervenche = "bleu_pervenche"
    case vertAtlantide = "vert_atlantide"
    case poussiereDeLune = "poussiere_de_lune"

    var displayName: String {
        switch self {
        case .emeraldOfChivor: return "Emerald of Chivor"
        case .stormyGrey: return "Stormy Grey"
        case .rougeHematite: return "Rouge Hematite"
        case .bleuPervenche: return "Bleu Pervenche"
        case .vertAtlantide: return "Vert Atlantide"
        case .poussiereDeLune: return "Poussiere de Lune"
        }
    }

    var color: Color {
        switch self {
        case .emeraldOfChivor:
            return Color(red: 0.15, green: 0.45, blue: 0.42)
        case .stormyGrey:
            return Color(red: 0.35, green: 0.42, blue: 0.52)
        case .rougeHematite:
            return Color(red: 0.55, green: 0.15, blue: 0.20)
        case .bleuPervenche:
            return Color(red: 0.40, green: 0.45, blue: 0.72)
        case .vertAtlantide:
            return Color(red: 0.18, green: 0.42, blue: 0.38)
        case .poussiereDeLune:
            return Color(red: 0.45, green: 0.35, blue: 0.55)
        }
    }

    var hasShimmer: Bool {
        switch self {
        case .emeraldOfChivor, .poussiereDeLune, .rougeHematite:
            return true
        default:
            return false
        }
    }

    var shimmerColor: Color {
        switch self {
        case .emeraldOfChivor:
            return Color(red: 0.85, green: 0.75, blue: 0.45).opacity(0.6)
        case .poussiereDeLune:
            return Color(red: 0.75, green: 0.75, blue: 0.85).opacity(0.6)
        case .rougeHematite:
            return Color(red: 0.85, green: 0.75, blue: 0.45).opacity(0.5)
        default:
            return .clear
        }
    }

    var description: String {
        switch self {
        case .emeraldOfChivor:
            return "Teal with gold shimmer"
        case .stormyGrey:
            return "Classic blue-grey"
        case .rougeHematite:
            return "Rich burgundy with gold"
        case .bleuPervenche:
            return "Soft periwinkle blue"
        case .vertAtlantide:
            return "Deep sea green"
        case .poussiereDeLune:
            return "Violet with silver shimmer"
        }
    }
}
