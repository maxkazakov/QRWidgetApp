
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
            case .square: return L10n.QrStyle.Eye.square
            case .circle: return L10n.QrStyle.Eye.circle
            case .roundedRect: return L10n.QrStyle.Eye.roundedRect
            case .roundedOuter: return L10n.QrStyle.Eye.roundedOuter
            case .roundedPointingIn: return L10n.QrStyle.Eye.roundedPointingIn
            case .leaf: return L10n.QrStyle.Eye.leaf
            case .squircle: return L10n.QrStyle.Eye.squircle
            case .barsHorizontal: return L10n.QrStyle.Eye.barsHorizontal
            case .barsVertical: return L10n.QrStyle.Eye.barsVertical
            case .pixels: return L10n.QrStyle.Eye.pixels
            case .corneredPixels: return L10n.QrStyle.Eye.corneredPixels
            case .edges: return L10n.QrStyle.Eye.edges
            case .shield: return L10n.QrStyle.Eye.shield
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
            case .square: return L10n.QrStyle.Pixels.square
            case .circle: return L10n.QrStyle.Pixels.circle
            case .curvePixel: return L10n.QrStyle.Pixels.curvePixel
            case .roundedPath: return L10n.QrStyle.Pixels.roundedPath
            case .roundedEndIndent: return L10n.QrStyle.Pixels.roundedEndIndent
            case .squircle: return L10n.QrStyle.Pixels.squircle
            case .pointy: return L10n.QrStyle.Pixels.pointy
            case .sharp: return L10n.QrStyle.Pixels.sharp
            case .star: return L10n.QrStyle.Pixels.star
            case .flower: return L10n.QrStyle.Pixels.flower
            case .shiny: return L10n.QrStyle.Pixels.shiny
            }
        }
    }

    public var eye: Eye
    public var onPixels: OnPixels
}

extension QRStyle: Codable {

}
