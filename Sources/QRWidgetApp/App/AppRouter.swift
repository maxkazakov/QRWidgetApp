
import UIKit
import SwiftUI
import QRWidgetCore

enum Route {
    case onboarding(onComplete: EmptyBlock)
    case beautify(CodeModel)
    case details(CodeModel, options: CodeDetailsPresentaionOptions = .zero, completion: EmptyBlock = {})
    case multipleCodesRecognized(codes: [CodeModel], completion: EmptyBlock)
    case mailToDeveloper(onComplete: (_ sent: Bool) -> Void)
}

class AppRouter {

    let mainRouter: Router
    let rootViewController: UIViewController

    init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController

        self.mainRouter = Router()
        self.mainRouter.routerController = rootViewController
    }

    func route(parentrRouter: Router? = nil, route: Route) {
        let router = parentrRouter ?? mainRouter
        switch route {
        case let .onboarding(onComplete):
            presentOnboarding(onComplete)
        case let .beautify(qrModel):
            presentBeautify(router: router, qrModel: qrModel)
        case let .details(qrModel, options, completion):
            presentDetails(router: router, qrModel: qrModel, options: options, completion: completion)
        case let .multipleCodesRecognized(codes, completion):
            presentMultipleCodesRecognized(router: router, codes: codes, completion: completion)
        case let .mailToDeveloper(onComplete):
            presentMailToDeveloper(router: router, completion: onComplete)
        }
    }

    private func presentMailToDeveloper(router: Router, completion: @escaping (_ sent: Bool) -> Void) {
        EmailSender().sendEmail(presentingController: router.routerController!, completion: completion)
    }

    private func presentMultipleCodesRecognized(router: Router, codes: [CodeModel], completion: @escaping EmptyBlock) {
        let module = generalAssembly.makeMultipleCodesRecognized(codes: codes, onClose: {
            router.dismiss(animated: true, completion: {
                completion()
            })
        })
        let viewController = module.controller
        viewController.modalPresentationStyle = .pageSheet
        let adaptivePresentationControllerDelegate = PageSheetPresentationControllerDelegate { completion() }
        viewController.presentationController?.delegate = adaptivePresentationControllerDelegate
        module.router.adaptivePresentationDelegate = adaptivePresentationControllerDelegate
        if #available(iOS 15.0, *) {
            if let sheet = viewController.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
            }
        }
        router.routerController?.present(viewController, animated: true, completion: nil)
    }

    private func presentOnboarding(_ onComplete: @escaping EmptyBlock) {
        let viewController = generalAssembly.makeOnboardingModule(onComplete: onComplete)
        viewController.modalPresentationStyle = .fullScreen
        rootViewController.present(viewController, animated: false, completion: nil)
    }

    private func presentBeautify(router: Router, qrModel: CodeModel) {
        let module = generalAssembly.makeBeautifyModule(qrModel: qrModel)
        let viewController = module.controller
        viewController.modalPresentationStyle = .fullScreen
        router.routerController?.present(module.controller, animated: true, completion: nil)
    }

    private func presentDetails(router: Router, qrModel: CodeModel, options: CodeDetailsPresentaionOptions, completion: @escaping EmptyBlock) {
        let module = generalAssembly.makeDetailsViewModule(qrModel: qrModel, options: options)
        let viewController = module.controller
        let navigationController = UINavigationController(rootViewController: viewController)

        let adaptivePresentationControllerDelegate = PageSheetPresentationControllerDelegate { completion() }
        navigationController.presentationController?.delegate = adaptivePresentationControllerDelegate
        module.router.adaptivePresentationDelegate = adaptivePresentationControllerDelegate

        navigationController.modalPresentationStyle = .pageSheet

        if #available(iOS 15.0, *), options.isPopup, let sheet = navigationController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
        }
        guard let presentingController = router.routerController else { return }
        let presentCall = { presentingController.present(navigationController, animated: true, completion: nil) }
        if presentingController.presentedViewController != nil {
            presentingController.dismiss(animated: false, completion: presentCall)
        } else {
            presentCall()
        }
    }
}

class PageSheetPresentationControllerDelegate: NSObject, UIAdaptivePresentationControllerDelegate {
    let onClose: EmptyBlock

    init(onClose: @escaping EmptyBlock) {
        self.onClose = onClose
        super.init()
    }
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        onClose()
    }
}
