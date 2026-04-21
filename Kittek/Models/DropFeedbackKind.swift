import Foundation

enum DropFeedbackKind: Equatable {
    case success
    case miss

    var title: String {
        switch self {
        case .success:
            return "YUM!"
        case .miss:
            return "TRY AGAIN"
        }
    }
}
