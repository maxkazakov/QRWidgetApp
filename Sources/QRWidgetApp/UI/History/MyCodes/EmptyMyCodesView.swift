
import SwiftUI

struct EmptyMyCodesView: View {
    init(createNewTapped: @escaping EmptyBlock) {
        self.createNewTapped = createNewTapped
    }

    let createNewTapped: EmptyBlock

    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(uiImage: Asset.emptyHistory.image)
            VStack(spacing: 8) {
                Text(L10n.MyCodes.Empty.title)
                    .font(.title3)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)

                Text(L10n.MyCodes.Empty.subtitle)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            Button(L10n.MyCodes.Empty.CreateNew.button, action: createNewTapped)
                .buttonStyle(.borderedProminent)
            Spacer()
        }
        .padding(20)
    }
}


struct EmptyMyCodesView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyMyCodesView(createNewTapped: {})
    }
}
