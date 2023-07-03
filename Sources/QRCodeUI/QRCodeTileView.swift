
import UIKit
import SwiftUI
import QRWidgetCore

struct QRCodeTileViewData: Equatable {
    let data: CodeModel.DataType
    let codeType: CodeType
    let foreground: CGColor
    let background: CGColor
    let errorCorrectionLevel: ErrorCorrection
    let qrStyle: QRStyle?
}

public struct QRCodeTileView: View {

    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @StateObject var viewModel = QRCodeTileViewModel()

    let data: QRCodeTileViewData
    let flipEnabled: Bool

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
        flipEnabled = true
    }

    public init(
        model: CodeModel,
        proVersionActivated: Bool,
        forcedForegroundColor: UIColor? = nil,
        forcedBackgroundColor: UIColor? = nil
    ) {
        let foregroundColor: CGColor
        if let forcedForegroundColor {
            foregroundColor = forcedForegroundColor.cgColor
        } else {
            foregroundColor = model.foregroundColor(isProActivated: proVersionActivated)
        }

        let backgroundColor: CGColor
        if let forcedBackgroundColor {
            backgroundColor = forcedBackgroundColor.cgColor
        } else {
            backgroundColor = model.backgroundColor(isProActivated: proVersionActivated)
        }

        self.data = QRCodeTileViewData(
            data: model.data,
            codeType: model.type,
            foreground: foregroundColor,
            background: backgroundColor,
            errorCorrectionLevel: model.errorCorrectionLevel,
            qrStyle: model.qrStyle
        )
        flipEnabled = proVersionActivated
            && (model.foregroundColor != nil || model.backgroundColor != nil)
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

            if let coloredImage = viewModel.coloredQrImage {
                Image(uiImage: coloredImage)
                    .decorateQr(backgroundColor: data.background, isDarkScheme: colorScheme == .dark)
                    .flipRotate(flipDegrees)
                    .opacity(viewModel.flipped ? 0.0 : 1.0)
            }

            if viewModel.isLoading, viewModel.coloredQrImage == nil {
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
            guard flipEnabled, viewModel.coloredQrImage != nil else { return }
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

    var hasChangedColors: Bool {
        return backgroundColor != nil || foregroundColor != nil
    }
}
