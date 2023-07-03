
import Foundation

public struct QRStyle: Equatable {
    public init(eye: QRStyle.Eye = .default, onPixels: QRStyle.OnPixels = .default) {
        self.eye = eye
        self.onPixels = onPixels
    }


    public enum Eye: Int, CaseIterable, Identifiable, Codable, Equatable {
        public var id: Int {
            return rawValue
        }

        case square = 0
        case circle
        case roundedRect
        case roundedOuter
        case roundedPointingIn
        case leaf
        case squircle
        case barsHorizontal
        case barsVertical
        case pixels
        case corneredPixels
        case edges
        case shield

        public static let `default` = Eye.square

        public var description: String {
            switch self {
            case .square:
                return "Square"
            case .circle:
                return "Circle"
            case .roundedRect:
                return "Rounded rectangle"
            case .roundedOuter:
                return "Rounded outer"
            case .roundedPointingIn:
                return "Rounded pointing in"
            case .leaf:
                return "Leaf"
            case .squircle:
                return "Squircle"
            case .barsHorizontal:
                return "Bars horizontal"
            case .barsVertical:
                return "Bars vertical"
            case .pixels:
                return "Pixels"
            case .corneredPixels:
                return "Cornered pixels"
            case .edges:
                return "Edges"
            case .shield:
                return "Shield"
            }
        }
    }

    public enum OnPixels: Int, CaseIterable, Identifiable, Codable, Equatable {
        public var id: Int {
            return rawValue
        }

        case square = 0
        case circle
        case curvePixel
        case roundedRect
        case horizontal
        case vertical
        case roundedPath
        case roundedEndIndent
        case squircle
        case pointy
        case sharp
        case star
        case flower
        case shiny

        public static let `default` = OnPixels.square

        public var description: String {
            switch self {
            case .square: return "Square"
            case .circle: return "Circle"
            case .curvePixel: return "Curve pixel"
            case .roundedRect: return "Rounded rect"
            case .horizontal: return "Horizontal"
            case .vertical: return "Vertical"
            case .roundedPath: return "Rounded path"
            case .roundedEndIndent: return "Rounded end indent"
            case .squircle: return "Squircle"
            case .pointy: return "Pointy"
            case .sharp: return "Sharp"
            case .star: return "Star"
            case .flower: return "Flower"
            case .shiny: return "Shiny"
            }
        }
    }

    public var eye: Eye
    public var onPixels: OnPixels
}

extension QRStyle: Codable {

}
