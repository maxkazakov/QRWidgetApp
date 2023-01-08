
import SwiftUI

struct NeedToBuyView: View {
    
    @State var isPaymentPresented = false
    
    var body: some View {
        HStack {
            VStack(spacing: 12) {
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    Image(systemName: "lock.fill")
                    Text(L10n.Subscription.expired)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(Color(UIColor.label))
                }

                Button(action: {
                    isPaymentPresented = true
                }, label: {
                    Text(L10n.activate)
                })
                    .buttonStyle(MainButtonStyle(titleColor: .white, backgroundColor: .systemPink))
            }
            .padding()
            .background(
                Color(UIColor.secondarySystemFill)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .circular))
        }
        .fullScreenCover(isPresented: self.$isPaymentPresented) {
            generalAssembly.makePaywallView(sourceScreen: .addSecondQrCore)
        }

    }
}

struct NeedToBuyView_Previews: PreviewProvider {
    static var previews: some View {
        NeedToBuyView()
    }
}
