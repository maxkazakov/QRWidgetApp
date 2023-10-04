import SwiftUI
import Haptica
import StoreKit
import Combine
import SwiftUINavigation

struct PaywallScreen: View {
    @StateObject var viewModel: PaywallViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        viewModel.tapCloseButton()
                    }, label: {
                        Image(systemName: "xmark")
                            .font(.headline)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                            .foregroundColor(Color(UIColor.white.withAlphaComponent(0.5)))
                    })
                    .opacity(viewModel.closeButtonIsHidden ? 0 : 1)
                    .animation(.easeInOut(duration: 2), value: viewModel.closeButtonIsHidden)

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

                                Text("Go Premium")
                                    .font(Font.system(size: 28, weight: .bold, design: .rounded))
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

                VStack(spacing: 20) {
                    AvailableProductsView(viewModel: viewModel)

                    buttonAndTerms()
                }
            }
            .disabled(viewModel.isLoading)

            if viewModel.isLoading {
                loaderView()
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
        .background(LinearGradient.vertical.ignoresSafeArea())
        .onChange(of: viewModel.needToClose, perform: {
            if $0 {
                presentationMode.wrappedValue.dismiss()
            }
        })
        .onAppear { viewModel.onAppear() }
        .alert(
            unwrapping: $viewModel.alert,
            case: /PaywallViewModel.Alert.error,
            action: {
                switch $0 {
                case .tapDismiss:
                    viewModel.tapOkOnAlert()
                }
            }
        )
    }

    @ViewBuilder
    func buttonAndTerms() -> some View {
        VStack(spacing: 8) {
            Button(action: {
                Haptic.impact(.medium).generate()
                viewModel.activate()
            }, label: {
                Text(L10n.continue)
            })
            .buttonStyle(MainButtonStyle(titleColor: Asset.primaryColor.color, backgroundColor: .white))
        }
    }

    @ViewBuilder
    func loaderView() -> some View {
        VStack {
            ProgressView()
                .controlSize(.large)
                .progressViewStyle(.circular)
                .padding(24)

                .background(
                    .regularMaterial,
                    in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        let viewModelStub = PaywallViewModel(
            source: .onboarding,
            purchasesEnvironment: .unimplemented,
            sendAnalyticsEvent: { _, _ in },
            onClose: {}
        )
        viewModelStub.products = productStubs
        return viewModelStub
    }

    static func makeSuccessStub() -> PaywallViewModel {
        var purchasesEnvironment: PurchasesEnvironment = .unimplemented
        purchasesEnvironment.offerings = {
            let products = productStubs
            return Just(products).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        let viewModelStub = PaywallViewModel(source: .onboarding,
                                             purchasesEnvironment: purchasesEnvironment,
                                             sendAnalyticsEvent: { _, _ in },
                                             onClose: {})
        return viewModelStub
    }

    static func makeLoadingStub() -> PaywallViewModel {
        let viewModelStub = PaywallViewModel(source: .onboarding, purchasesEnvironment: .unimplemented, sendAnalyticsEvent: { _,_ in }, onClose: {})
        viewModelStub.isLoading = true
        return viewModelStub
    }
}

private let productStubs: [QRProduct] = [
    .init(
        id: "1",
        isPopular: false,
        title: "$6.99 / month",
        subtitle: "after 7 days trial period",
        safePercent: nil,
        type: .subscription,
        purchase: { Just(()).setFailureType(to: PurchasesError.self).eraseToAnyPublisher() }
    ),
    .init(
        id: "2",
        isPopular: true,
        title: "$29.99 / year",
        subtitle: "$2.49 / month billed annually",
        safePercent: 61,
        type: .subscription,
        purchase: { Just(()).setFailureType(to: PurchasesError.self).eraseToAnyPublisher() }
    )
]
