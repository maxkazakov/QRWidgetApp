
import SwiftUI

struct NoHistoryView: View {
    init(startScanningTapped: @escaping EmptyBlock) {
        self.startScanningTapped = startScanningTapped
    }

    let startScanningTapped: EmptyBlock

    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(uiImage: Asset.emptyHistory.image)
            VStack(spacing: 8) {
                Text(L10n.History.Empty.title)
                    .font(.title3)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)

                Text(L10n.History.Empty.subtitle)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            Button(L10n.StartScanningButton.title, action: startScanningTapped)
                .buttonStyle(.borderedProminent)
            Spacer()
        }
        .padding(20)
    }
}


struct NoHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        NoHistoryView(startScanningTapped: {})
    }
}
