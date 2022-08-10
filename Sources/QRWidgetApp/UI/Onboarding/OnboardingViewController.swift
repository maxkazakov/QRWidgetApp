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
