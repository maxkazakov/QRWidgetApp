
import SwiftUI
import QRWidgetCore

struct QRCodeDataView: View {

    let codeContent: CodeContent
    @Environment(\.sendAnalyticsEvent) var sendAnalyticsEvent

    var body: some View {
        switch self.codeContent {
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
            })

        case let .rawText(text):
            Text(text)
                .multilineTextAlignment(.leading)
                .lineLimit(4)

        case .binary:
            Text("Binary content")
                .multilineTextAlignment(.leading)
                .lineLimit(4)
                .foregroundColor(Color.primary)

        case let .phone(phone):
            Button(action: {
                if UIApplication.shared.canOpenURL(phone) {
                    UIApplication.shared.open(phone, options: [:], completionHandler: nil)
                    sendAnalyticsEvent(.tapPhoneNumberLink, nil)
                }
            }, label: {
                Text(phone.absoluteString)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
            })

        case let .email(email):
            Button(action: {
                if UIApplication.shared.canOpenURL(email) {
                    UIApplication.shared.open(email, options: [:], completionHandler: nil)
                    sendAnalyticsEvent(.tapEmailLink, nil)
                }
            }, label: {
                Text(email.absoluteString)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
            })
        }
    }
}

struct QRCodeView: View {
    let codeContent: CodeContent

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(codeContent.type.title)
                .foregroundColor(Color.gray)
            HStack {
                QRCodeDataView(codeContent: codeContent)
                Spacer()
            }
        }
    }
}

struct QRCodeDataView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            QRCodeView(codeContent: .rawText("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."))
            QRCodeView(codeContent: .url(URL(string: "http://tbilisi.regionshop.biz/sports.html")!))
            QRCodeView(codeContent: .phone(URL(string: "tel:89273325479")!))
            QRCodeView(codeContent: .email(URL(string: "mailto:maxkazakov@gmail.com")!))
        }
    }
}
