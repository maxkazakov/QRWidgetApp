//
//  QRCodeTileView.swift
//  QRWidget
//
//  Created by Максим Казаков on 06.01.2022.
//

import SwiftUI
import QRWidgetCore

struct QRCodeTileViewData: Equatable {
    let qrData: String
    let foreground: CGColor
    let background: CGColor
    let errorCorrectionLevel: ErrorCorrection
}

struct QRCodeTileView: View {

    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.sendAnalyticsEvent) var sendAnalyticsEvent
    @StateObject var viewModel = QRCodeTileViewModel()

    let data: QRCodeTileViewData
    let flipEnabled: Bool

    init(qrData: String, foreground: CGColor = .qr.defaultForeground, background: CGColor = .qr.defaultBackground, errorCorrectionLevel: ErrorCorrection) {
        self.data = QRCodeTileViewData(qrData: qrData,
                                       foreground: foreground,
                                       background: background,
                                       errorCorrectionLevel: errorCorrectionLevel)
        flipEnabled = false
    }

    init(model: QRModel, proVersionActivated: Bool) {
        self.data = QRCodeTileViewData(qrData: model.qrData,
                                       foreground: model.foregroundColor(isProActivated: proVersionActivated),
                                       background: model.backgroundColor(isProActivated: proVersionActivated),
                                       errorCorrectionLevel: model.errorCorrectionLevel)
        flipEnabled = proVersionActivated
            && (model.foregroundColor != nil || model.backgroundColor != nil)
    }

    var body: some View {
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

            sendAnalyticsEvent(.flipQrImage, nil)
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

extension QRModel {
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
