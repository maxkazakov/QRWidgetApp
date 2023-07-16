
import UIKit
import SwiftUI
import QRWidgetCore
import CodeImageGenerator

struct QRCodeTileViewData: Equatable {
    let data: CodeModel.DataType
    let codeType: CodeType
    let foreground: CGColor
    let background: CGColor
    let errorCorrectionLevel: ErrorCorrection
    let qrStyle: QRStyle?

    var isDefaultSettings: Bool {
        if foreground != CGColor.qr.defaultForeground || background != CGColor.qr.defaultBackground {
            return false
        }
        if let qrStyle,
           qrStyle.eye != .default || qrStyle.onPixels != .default {
            return false
        }
        return true
    }
}

public struct QRCodeTileView: View {

    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @StateObject var viewModel = QRCodeTileViewModel()

    let data: QRCodeTileViewData

    public init(
         data: CodeModel.DataType,
         codeType: CodeType,
         foreground: CGColor = .qr.defaultForeground,
         background: CGColor = .qr.defaultBackground,
         errorCorrectionLevel: ErrorCorrection = .default,
         qrStyle: QRStyle? = nil
    ) {
        self.data = QRCodeTileViewData(
            data: data,
            codeType: codeType,
            foreground: foreground,
            background: background,
            errorCorrectionLevel: errorCorrectionLevel,
            qrStyle: qrStyle
        )
    }

    public init(
        model: CodeModel,
        proVersionActivated: Bool
    ) {
        self.data = QRCodeTileViewData(
            data: model.data,
            codeType: model.type,
            foreground: model.foregroundColor(isProActivated: proVersionActivated),
            background: model.backgroundColor(isProActivated: proVersionActivated),
            errorCorrectionLevel: model.errorCorrectionLevel,
            qrStyle: model.qrStyle(isProActivated: proVersionActivated)
        )
    }

    public var body: some View {
        let flipDegrees = viewModel.flipped ? 180.0 : 0

        return ZStack {
            if let image = viewModel.blackAndWhiteQRImage {
                Image(uiImage: image)
                    .decorateQr(backgroundColor: CGColor.qr.defaultBackground, isDarkScheme: colorScheme == .dark)
                    .flipRotate(-180 + flipDegrees)
                    .opacity(viewModel.flipped ? 1.0 : 0.0)
            }

            if let coloredImage = viewModel.modifiedAppearanceImage {
                Image(uiImage: coloredImage)
                    .decorateQr(backgroundColor: data.background, isDarkScheme: colorScheme == .dark)
                    .flipRotate(flipDegrees)
                    .opacity(viewModel.flipped ? 0.0 : 1.0)
            }

            if viewModel.isLoading, viewModel.modifiedAppearanceImage == nil {
                ZStack {
                    Image(uiImage: Asset.placeholder.image)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color(UIColor.systemGray5))
                }
                .frame(width: 200, height: 200)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: viewModel.flipped)
        .onTapGesture {
            guard viewModel.flipEnabled, viewModel.modifiedAppearanceImage != nil else { return }
            self.viewModel.flipped.toggle()
        }
        .onAppear(perform: {
            viewModel.update(data)
        })
        .onChange(of: data, perform: {
            viewModel.update($0)
        })
        .frame(width: 200, height: 200)
    }
}

extension View {
    func flipRotate(_ degrees : Double) -> some View {
        return rotation3DEffect(Angle(degrees: degrees), axis: (x: 1.0, y: 0.0, z: 0.0))
    }
}

extension Image {
    @ViewBuilder
    func decorateQr(backgroundColor: CGColor, isDarkScheme: Bool) -> some View {
        self
            .resizable()
            .interpolation(.none)
            .scaledToFit()
            .frame(width: 200, height: 200)
            .padding(.all, 8)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color(backgroundColor))
                    .shadow(color: isDarkScheme ?.clear : .gray, radius: 6, x: 0, y: 3)
            )
    }
}

extension CodeModel {
    func foregroundColor(isProActivated: Bool) -> CGColor {
        guard isProActivated else {
            return CGColor.qr.defaultForeground
        }
        return foregroundColor?.cgColor ?? CGColor.qr.defaultForeground
    }

    func backgroundColor(isProActivated: Bool) -> CGColor {
        guard isProActivated else {
            return CGColor.qr.defaultBackground
        }
        return backgroundColor?.cgColor ?? CGColor.qr.defaultBackground
    }

    func qrStyle(isProActivated: Bool) -> QRStyle? {
        guard isProActivated else {
            return nil
        }
        return self.qrStyle
    }
}
