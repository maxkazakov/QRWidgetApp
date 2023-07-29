
import UIKit
import SwiftUI
import Haptica

enum OnboardingPage: Int, Identifiable {
    var id: Int {
        return self.rawValue
    }
    case step1
    case step2
    case step3
    case paywall

    static let orderedPages: [OnboardingPage] = [.step1, .step2, .step3, .paywall]
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
        case .step1:
            OnboardingPageView(titleText: L10n.Onboarding.Step1.title, image: {
                Image(uiImage: Asset.Onboarding.step1.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: UIScreen.main.bounds.size.width - 50)

            }, onTapContinue: { [weak self] in
                self?.sendAnalytics(.tapContinueOnStep1, nil)
                self?.goToNextPage()
            })

        case .step2:
            OnboardingPageView(titleText: L10n.Onboarding.Step2.title, image: {
                Image(uiImage: Asset.Onboarding.step2.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: UIScreen.main.bounds.size.width - 50)

            }, onTapContinue: { [weak self] in
                self?.sendAnalytics(.tapContinueOnStep2, nil)
                self?.goToNextPage()
            })
        case .step3:
            OnboardingPageView(titleText: L10n.Onboarding.Step3.title, image: {
                Image(uiImage: Asset.Onboarding.step3.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: UIScreen.main.bounds.size.width - 50)

            }, onTapContinue: { [weak self] in
                self?.sendAnalytics(.tapContinueOnStep3, nil)
                self?.goToNextPage()
            })
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
