//
//  QRWidget.swift
//  QRWidget
//
//  Created by Максим Казаков on 10.08.2022.
//

import WidgetKit
import SwiftUI

struct Provider: IntentTimelineProvider {

    func placeholder(in context: Context) -> QREntry {
        .init(qrWidgetData: .placeholder)
    }

    func getSnapshot(for configuration: DynamicQRSelectionIntent, in context: Context, completion: @escaping (QREntry) -> Void) {
        if context.isPreview {
            completion(.init(qrWidgetData: .preview))
        } else {
            let entry = qrEntry(for: configuration)
            completion(entry)
        }
    }

    func getTimeline(for configuration: DynamicQRSelectionIntent, in context: Context, completion: @escaping (Timeline<QREntry>) -> ()) {
        DispatchQueue.global().async {
            let entry = qrEntry(for: configuration)
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
}

@main
struct QRWidgets: WidgetBundle {
    var body: some Widget {
        QRWidgetExt()
    }
}

struct QRWidgetExt: Widget {
    let kind: String = "QRWidgetExtDynamic"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: DynamicQRSelectionIntent.self, provider: Provider()) { entry in
            QRWidgetExtEntryView(entry: entry)
        }
        .configurationDisplayName("QR Widget")
        .description(NSLocalizedString("Widget for displaying QR-code on main screen", comment: ""))
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

import QRGenerator
import QRWidgetCore

struct QRWidgetExtEntryView : View {
    var entry: Provider.Entry
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        switch entry.qrWidgetData {
        case .placeholder:
            ZStack {
                Image("placeholder")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color(UIColor.systemGray5))
            }

        case .preview:
            qrCodeView(QRModel(id: UUID(),
                               dateCreated: Date(),
                               qrData: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
                               label: NSLocalizedString("Your text here", comment: ""),
                               errorCorrectionLevel: .L,
                               backgroundColor: nil,
                               foregroundColor: nil,
                               batchId: nil))

        case let .real(qrModel):
            if let qrModel = qrModel {
                qrCodeView(qrModel)
            } else {
                ZStack {
                    Text(NSLocalizedString("Add any QR-code to Favorites", comment: ""))
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
                        .multilineTextAlignment(.center)
                        .padding(8)
                }
            }
        }
    }

    var backgroundColor: UIColor {
        entry.qrWidgetData.qrModel?.backgroundColor ?? .white
    }

    var labelColor: UIColor {
        let isBackgroundLight = entry.qrWidgetData.qrModel?.backgroundColor?.isLight() ?? true
        return isBackgroundLight ? .black : .white
    }

    @ViewBuilder
    func qrCodeView(_ qrModel: QRModel) -> some View {
        ZStack {
            Color(backgroundColor)
            VStack(spacing: 0) {
                Image(uiImage: QRCodeGenerator.shared.generateQRCode(from: qrModel, useCustomColorsIfPossible: true) ?? UIImage())
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .padding(.top, 8)
                    .padding(.horizontal, 8)

                if !qrModel.label.isEmpty {
                    Text(qrModel.label)
                        .font(.caption2)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                        .foregroundColor(Color(labelColor))
                }
            }
            .padding(.bottom, qrModel.label.isEmpty ? 8 : 4)
        }
        .widgetURL(Foundation.URL(string: "qrwidget://\(qrModel.id)"))
    }
}

extension UIColor {

    // Check if the color is light or dark, as defined by the injected lightness threshold.
    // Some people report that 0.7 is best. I suggest to find out for yourself.
    // A nil value is returned if the lightness couldn't be determined.
    func isLight(threshold: Float = 0.5) -> Bool? {
        let originalCGColor = self.cgColor

        // Now we need to convert it to the RGB colorspace. UIColor.white / UIColor.black are greyscale and not RGB.
        // If you don't do this then you will crash when accessing components index 2 below when evaluating greyscale colors.
        let RGBCGColor = originalCGColor.converted(to: CGColorSpaceCreateDeviceRGB(), intent: .defaultIntent, options: nil)
        guard let components = RGBCGColor?.components else {
            return nil
        }
        guard components.count >= 3 else {
            return nil
        }

        let brightness = Float(((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000)
        return (brightness > threshold)
    }
}

