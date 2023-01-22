
import SwiftUI

struct PaywallOffersErrorView: View {
    let onClose: () -> Void
    let onRepeat: () -> Void
    let errorMessage: String

    var body: some View {
        VStack(spacing: 30) {
            Text(errorMessage)
                .font(.body)
                .lineLimit(4)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
            Button(action: {
                onRepeat()
            }, label: {
                Text(L10n.repeat)
            })
            .buttonStyle(MainButtonStyle(titleColor: Asset.primaryColor.color, backgroundColor: .white))
        }
        .padding()
    }
}

struct PaywallOffersErrorView_Previews: PreviewProvider {
    static var previews: some View {
        PaywallOffersErrorView(onClose: {}, onRepeat: {}, errorMessage: "Something went wrong")
    }
}
