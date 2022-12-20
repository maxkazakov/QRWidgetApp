import SwiftUI

public struct QRCodeTypeView: View {
    let type: QRCodeType

    public init(type: QRCodeType) {
        self.type = type
    }

    public var body: some View {
        switch self.type {
        case .url:
            HStack {
                Text("Website")
                Spacer()
            }
            .font(.callout)
            .imageScale(.small)
            .foregroundColor(Color.gray)

        case .rawText:
            HStack {
                Text("Text")
                Spacer()
            }
            .font(.callout)
            .imageScale(.small)
            .foregroundColor(Color.gray)
        }
    }
}
