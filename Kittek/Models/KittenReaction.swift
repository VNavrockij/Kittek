import Foundation

enum KittenReaction: Equatable {
    case idle
    case happy
    case sad
    case victory

    func imageName(isComplete: Bool) -> String {
        if isComplete {
            return "Test_Kitten_Victory 1"
        }

        switch self {
        case .idle:
            return "Test_Kitten 1"
        case .happy:
            return "Test_Kitten_Happy 1"
        case .sad:
            return "Test_Kitten_Sad 1"
        case .victory:
            return "Test_Kitten_Victory 1"
        }
    }
}
