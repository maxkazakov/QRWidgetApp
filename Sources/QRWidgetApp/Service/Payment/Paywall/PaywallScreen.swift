import SwiftUI
import Haptica
import StoreKit
import Combine
import Lottie

struct PaywallScreen: View {
    @ObservedObject var viewModel: PaywallViewModel

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        viewModel.close()
                    }, label: {
                        Image(systemName: "xmark")
                            .font(.headline)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                            .foregroundColor(Color(UIColor.white.withAlphaComponent(0.5)))
                    })
                    Spacer()
                    Button(action: {
                        viewModel.restore()
                    }, label: {
                        Text(L10n.Paywall.restore)
                            .foregroundColor(Color(UIColor.white.withAlphaComponent(0.7)))
                    })
                }

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        VStack(spacing: 8) {
                            HStack(alignment: .center) {
                                Image(uiImage: Asset.star.image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 28, height: 28)

                                Text(L10n.Paywall.proVersion)
                                    .font(Font.system(size: 28, weight: .bold, design: .default))
                                    .foregroundColor(.white)
                            }

                            HStack {
                                VStack(alignment: .leading, spacing: 16) {
                                    FeatureView(name: L10n.Paywall.Feature.AppleWallet.title,
                                                subtitle: L10n.Paywall.Feature.AppleWallet.subtitle,
                                                icon: "wallet.pass")

                                    FeatureView(name: L10n.Paywall.Feature.BatchScan.title,
                                                subtitle: L10n.Paywall.Feature.BatchScan.subtitle,
                                                icon: "folder")

                                    FeatureView(name: L10n.Paywall.Feature.Customization.title,
                                                subtitle: L10n.Paywall.Feature.Customization.subtitle,
                                                icon: "paintpalette"
                                    )

                                    FeatureView(name: L10n.Paywall.Feature.Widgets.title,
                                                subtitle: L10n.Paywall.Feature.Widgets.subtitle,
                                                icon: "apps.iphone")

                                    FeatureView(name: L10n.Paywall.Feature.AppleWatch.title,
                                                subtitle: L10n.Paywall.Feature.AppleWatch.subtitle,
                                                icon: "applewatch")
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                        }
                    }

                    Color.clear.frame(height: 10)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 20)

                switch viewModel.state {
                case .data, .loading:
                    VStack(spacing: 20) {
                        ProductsInfoView(viewModel: viewModel)
                            .padding(.horizontal, 12)
                        buttonAndTerms()
                    }
                case .error(let errorMessage):
                    PaywallOffersErrorView(onClose: { viewModel.close() },
                                           onRepeat: { viewModel.start() },
                                           errorMessage: errorMessage)
                default:
                    EmptyView()
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
        .background(LinearGradient.vertical.ignoresSafeArea())
    }

    @ViewBuilder
    func buttonAndTerms() -> some View {
        VStack(spacing: 8) {
            if viewModel.state == .loading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                    .frame(height: 50)
            } else {
                Button(action: {
                    Haptic.impact(.medium).generate()
                    viewModel.activate()
                }, label: {
                    Text(L10n.continue)
                })
                .buttonStyle(MainButtonStyle(titleColor: Asset.primaryColor.color, backgroundColor: .white))
            }
        }
    }
}

struct PaywallScreen_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PaywallScreen(viewModel: PaywallViewModel.makeSuccessStub())

            PaywallScreen(viewModel: PaywallViewModel.makeFailueStub())
                .previewDevice(PreviewDevice(rawValue: "iPhone 8"))
                .environment(\.locale, .init(identifier: "ru"))

            PaywallScreen(viewModel: PaywallViewModel.makeLoadingStub())
                .previewDevice(PreviewDevice(rawValue: "iPhone 8"))
                .environment(\.locale, .init(identifier: "ru"))
        }
    }
}

extension PaywallViewModel {
    static func makeFailueStub() -> PaywallViewModel {
        let viewModelStub = PaywallViewModel(source: .onboarding,
                                             purchasesEnvironment: .unimplemented,
                                             sendAnalyticsEvent: { _, _ in },
                                             onClose: {})
        viewModelStub.state = .error("Failed to load")
        viewModelStub.products = productStubs
        return viewModelStub
    }

    static func makeSuccessStub() -> PaywallViewModel {
        let viewModelStub = PaywallViewModel(source: .onboarding,
                                             purchasesEnvironment: .unimplemented,
                                             sendAnalyticsEvent: { _, _ in },
                                             onClose: {})
        viewModelStub.state = .data
        viewModelStub.products = productStubs
        return viewModelStub
    }

    static func makeLoadingStub() -> PaywallViewModel {
        let viewModelStub = PaywallViewModel(source: .onboarding, purchasesEnvironment: .unimplemented, sendAnalyticsEvent: { _,_ in }, onClose: {})
        viewModelStub.state = .loading
        return viewModelStub
    }
}

private let productStubs: [QRProduct] = [
    .init(
        id: "1",
        isPopular: false,
        title: "7 days Free",
        priceInfo: "Then $9.99 1 month",
        type: .subscription,
        purchase: { Just(()).setFailureType(to: PurchasesError.self).eraseToAnyPublisher() }
    ),
    .init(
        id: "2",
        isPopular: true,
        title: "One time purchase",
        priceInfo: "$29.99",
        type: .oneTime,
        purchase: { Just(()).setFailureType(to: PurchasesError.self).eraseToAnyPublisher() }
    )
]

extension QRProduct {
    static func mock(id: String) -> QRProduct {
        QRProduct(
            id: id,
            isPopular: true,
            title: "------------------------------------------------------------",
            priceInfo: "------------------------------------------------------------",
            type: .oneTime,
            purchase: { Just(()).setFailureType(to: PurchasesError.self).eraseToAnyPublisher() }
        )
    }
}
