import Foundation

enum Food: String, CaseIterable, Identifiable {
    case strawberry = "Strawberry"
    case banana = "Banana"
    case apple = "Apple"
    case raspberry = "Raspberry"
    case kiwi = "Kiwi"

    var id: String { rawValue }
    var shapeAssetName: String { "\(rawValue)_shape 1" }
    var guessedAssetName: String { "\(rawValue)_guessed 1" }
    var circleAssetName: String { "\(rawValue)_circle 1" }
}
