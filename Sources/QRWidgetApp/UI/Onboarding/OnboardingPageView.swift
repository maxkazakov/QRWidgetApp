//
//  OnboardingPageView.swift
//  QRWidget
//
//  Created by Максим Казаков on 09.01.2022.
//

import SwiftUI
//import Lottie

struct OnboardingPageView<CenterImage: View>: View {
    let titleText: String
    let image: () -> CenterImage
    let onTapContinue: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text(titleText)
                .font(Font.system(size: 38, weight: .heavy, design: .default))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Spacer()
            image()

            Spacer()
            Spacer()

            Button(action: {
                onTapContinue()
            }, label: {
                Text(L10n.continue)
                    .onTapGesture {
                        onTapContinue()
                    }
            })
            .buttonStyle(MainButtonStyle(titleColor: Asset.primaryColor.color, backgroundColor: .white))
            .padding(.bottom, 22)
        }
        .padding(.top, 40)
        .padding(.all)
        .background(LinearGradient.vertical.ignoresSafeArea())
    }
}

//struct OnboardingPageView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            OnboardingPageView(titleText: "QR-code on main screen", image: {
//                Image.init(uiImage: UIImage(named: "QrImageOnboarding")!)
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(maxWidth: 250)
//
//            }, onTapContinue: {})
//            OnboardingPageView(titleText: "Apple Wallet Pass", image: {
//                LottieView(name: "wallet")
//                    .aspectRatio(contentMode: .fit)
//                    .frame(maxWidth: 230)
//
//            }, onTapContinue: {})
//            OnboardingPageView(titleText: "All QR-codes in one place", image: {
//                LottieView(name: "sittingOnPhone")
//                    .aspectRatio(contentMode: .fit)
//                    .frame(maxWidth: 300)
//
//            }, onTapContinue: {})
//        }
//    }
//}
