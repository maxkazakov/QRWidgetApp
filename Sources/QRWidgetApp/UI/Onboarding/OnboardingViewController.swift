//
//  OnboardingViewController.swift
//  QRWidget
//
//  Created by Максим Казаков on 25.04.2022.
//

import UIKit
import SwiftUI
import Haptica

enum OnboardingPage: Int, Identifiable {
    var id: Int {
        return self.rawValue
    }

//    case qrOnMainScreen
//    case walletPass
//    case allQrInOnePlace
    case paywall

    static let orderedPages: [OnboardingPage] = [.paywall]
}

class OnboardingViewController: UIPageViewController {

    private var onboardingPageViewControllers: [UIViewController] = []
    private let onComplete: EmptyBlock?
    private let sendAnalytics: SendAnalyticsAction

    init(onComplete: EmptyBlock?, sendAnalytics: @escaping SendAnalyticsAction) {
        self.onComplete = onComplete
        self.sendAnalytics = sendAnalytics
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        sendAnalytics(.showOnboarding, nil)
//        AnimationsCache.shared.cacheAnimations()

        createViewControllers()
        if let firstViewController = onboardingPageViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        dataSource = self
    }

    private func createViewControllers() {
        self.onboardingPageViewControllers = OnboardingPage.orderedPages.map {
            UIHostingController(rootView: pageView(page: $0))
        }
    }

    @ViewBuilder
    func pageView(page: OnboardingPage) -> some View {
        switch page {
//        case .qrOnMainScreen:
//            OnboardingPageView(titleText: L10n.Onboarding.qrOnMainScreen, image: {
//                Image(uiImage: UIImage(named: "QrImageOnboarding")!)
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(maxWidth: 250)
//            }, onTapContinue: { [weak self] in
//                Haptic.impact(.medium).generate()
//                self?.sendAnalytics(.tapContinueOnQrOnMainOnboarding, nil)
//                self?.goToNextPage()
//            })
//
//        case .walletPass:
//            OnboardingPageView(titleText: L10n.QrDetails.appleWalletPass, image: {
//                LottieView(name: "wallet")
//                    .aspectRatio(contentMode: .fit)
//                    .frame(maxWidth: 230)
//            }, onTapContinue: { [weak self] in
//                self?.sendAnalytics(.tapContinueOnAppleWalletPassOnboarding, nil)
//                Haptic.impact(.medium).generate()
//                self?.goToNextPage()
//            })
//
//        case .allQrInOnePlace:
//            OnboardingPageView(titleText: L10n.Onboarding.allQRCodesInOnePlace, image: {
//                LottieView(name: "sittingOnPhone")
//                    .aspectRatio(contentMode: .fit)
//                    .frame(maxWidth: 300)
//            }, onTapContinue: { [weak self] in
//                self?.sendAnalytics(.tapContinueOnAllQRInOncePlaceOnboarding, nil)
//                Haptic.impact(.medium).generate()
//                self?.goToNextPage()
//            })

        case .paywall:
            generalAssembly.makePaywallView(
                sourceScreen: .onboarding,
                shownFromOnboarding: true,
                onClose: { [weak self] in
                    self?.onComplete?()
                }
            )
        }
    }

    func goToNextPage() {
        guard let currentViewController = self.viewControllers?.first else { return }
        guard let nextViewController = dataSource?.pageViewController( self, viewControllerAfter: currentViewController ) else { return }
        setViewControllers([nextViewController], direction: .forward, animated: true, completion: nil)
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = onboardingPageViewControllers.firstIndex(of: viewController) else {
            return nil
        }

        // Don't let go back from paywall
        if let currentPage = OnboardingPage(rawValue: viewControllerIndex), currentPage == .paywall {
            return nil
        }

        let previousIndex = viewControllerIndex - 1

        guard previousIndex >= 0 else {
            return nil
        }

        guard onboardingPageViewControllers.count > previousIndex else {
            return nil
        }

        return onboardingPageViewControllers[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = onboardingPageViewControllers.firstIndex(of: viewController) else {
            return nil
        }

        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = onboardingPageViewControllers.count

        guard orderedViewControllersCount != nextIndex else {
            return nil
        }

        guard orderedViewControllersCount > nextIndex else {
            return nil
        }

        return onboardingPageViewControllers[nextIndex]
    }
}
