//
//  QRPageItemView.swift
//  QRWidget
//
//  Created by Максим Казаков on 29.10.2021.
//

import SwiftUI
import QRWidgetCore

struct QRPageItemView: View {
    let model: QRModel
    let proVersionActivated: Bool
    @Environment(\.sendAnalyticsEvent) var sendAnalyticsEvent
    var forcedForegroundColor: UIColor? = nil

    var body: some View {
        ZStack {
            VStack(spacing: 25) {
                VStack(spacing: 20) {
                    if model.label.isEmpty {
                        Text(L10n.Qr.noname)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(UIColor.secondaryLabel))
                    } else {
                        Text(model.label)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                    }

                    QRCodeTileView(
                        model: model,
                        proVersionActivated: proVersionActivated,
                        forcedForegroundColor: forcedForegroundColor
                    )
                    .padding(.horizontal, 12)
                }
//
//                Button(action: {
//                    sendAnalyticsEvent(.openDetails, ["source": AnalyticsSource.OpenDetails.favorites.rawValue])
//                    generalAssembly.appRouter.route(route: .details(model))
//                }, label: {
//                    HStack(alignment: .firstTextBaseline) {
//                        Image(systemName: "pencil.circle.fill")
//                            .imageScale(.large)
//                        Text(L10n.ShowDetails.Button.title)
//                    }
//                })
            }
        }

    }
}
