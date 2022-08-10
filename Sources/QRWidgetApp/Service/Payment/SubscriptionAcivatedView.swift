//
//  SubscriptionAcivatedView.swift
//  QRWidget
//
//  Created by Максим Казаков on 26.10.2021.
//

import SwiftUI
import Lottie

struct SubscriptionAcivatedView: View {

    let onContinue: () -> Void
    @Environment(\.sendAnalyticsEvent) var sendAnalyticsEvent

    var body: some View {
        VStack(spacing: 30) {
            
            Spacer()

            LottieView(name: "congrats")
                .frame(width: 300, height: 300)

            Text(L10n.Subscription.activated)
                .font(Font.system(size: 22, weight: .bold, design: .default))
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                
            Spacer()
            
            Button(action: {
                sendAnalyticsEvent(.tapContinueOnCongratsScreen, nil)
                onContinue()
            }, label: {
                Text(L10n.continue)
            })
                .buttonStyle(MainButtonStyle(titleColor: .primaryColor, backgroundColor: .white))
        }
        .padding()
        .background(LinearGradient.vertical.ignoresSafeArea())
    }
}

struct SubscriptionAcivatedView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionAcivatedView(onContinue: {})
    }
}
