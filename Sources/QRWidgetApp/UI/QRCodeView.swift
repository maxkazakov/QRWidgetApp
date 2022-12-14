//
//  QRCodeDataView.swift
//  QRWidget
//
//  Created by Максим Казаков on 23.02.2022.
//

import SwiftUI
import QRWidgetCore

struct QRCodeTypeView: View {
    let type: QRCodeDataType

    var body: some View {
        switch self.type {
        case .url:
            HStack {
                Text(L10n.QrType.website)
                Spacer()
            }
            .font(.callout)
            .imageScale(.small)
            .foregroundColor(Color.gray)

        case .rawText:
            HStack {
                Text(L10n.QrType.text)
                Spacer()
            }
            .font(.callout)
            .imageScale(.small)
            .foregroundColor(Color.gray)
        }
    }
}

struct QRCodeDataView: View {

    let type: QRCodeDataType
    @Environment(\.sendAnalyticsEvent) var sendAnalyticsEvent

    var body: some View {
        switch self.type {
        case let .url(url):
            Button(action: {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    sendAnalyticsEvent(.tapQRLink, nil)
                }
            }, label: {
                Text(url.absoluteString)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .foregroundColor(Color.primaryColor)
            })

        case let .rawText(text):
            Text(text)
                .multilineTextAlignment(.leading)
                .lineLimit(4)
                .foregroundColor(Color.primary)
        }
    }
}

struct QRCodeView: View {
    let type: QRCodeDataType

    var body: some View {
        VStack(spacing: 4) {
            QRCodeTypeView(type: type)
            HStack {
                QRCodeDataView(type: type)
                Spacer()
            }
        }
    }
}

struct QRCodeDataView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            QRCodeView(type: .rawText("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."))
            QRCodeView(type: .url(URL(string: "http://tbilisi.regionshop.biz/sports.html")!))
        }
    }
}
