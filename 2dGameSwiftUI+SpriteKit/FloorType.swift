import Foundation

enum FloorType: CaseIterable {
    case small
    case medium
    case large
    
    var width: CGFloat {
        switch self {
        case .small: return 250
        case .medium: return 300
        case .large: return 500
        }
    }
    
}
