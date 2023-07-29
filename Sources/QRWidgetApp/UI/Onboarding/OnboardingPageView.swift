

import SwiftUI

struct OnboardingPageView<CenterImage: View>: View {
    let titleText: String
    let image: () -> CenterImage
    let onTapContinue: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text(titleText)
                .font(Font.system(size: 34, weight: .heavy, design: .rounded))
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
        }
        .padding(.top, 40)
        .padding(.horizontal)
        .padding(.bottom)
        .background(LinearGradient.vertical.ignoresSafeArea())
    }
}

struct OnboardingPageView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OnboardingPageView(titleText: "Scan, create, customize and store all types of codes", image: {
                Image(uiImage: Asset.Onboarding.step1.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: UIScreen.main.bounds.size.width - 50)

            }, onTapContinue: {})
            OnboardingPageView(titleText: "QR codes widgets on main screen", image: {
                Image(uiImage: Asset.Onboarding.step2.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: UIScreen.main.bounds.size.width - 50)

            }, onTapContinue: {})
            OnboardingPageView(titleText: "Add to Wallet Pass and Apple Watch", image: {
                Image(uiImage: Asset.Onboarding.step3.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: UIScreen.main.bounds.size.width - 50)

            }, onTapContinue: {})
        }
    }
}
