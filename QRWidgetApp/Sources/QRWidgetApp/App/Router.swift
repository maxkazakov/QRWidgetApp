//
//  Router.swift
//  QRWidget
//
//  Created by Максим Казаков on 18.01.2022.
//

import Combine
import SwiftUI

enum PresentKind {
    case modal
}

public typealias EmptyBlock = () -> Void

class Module {
    let router: Router
    let controller: UIViewController

    init(router: Router = Router(), controller: UIViewController) {
        self.router = router
        self.controller = controller
        router.routerController = controller
    }

    init(router: Router = Router(), view: AnyView, statusBarStyle: UIStatusBarStyle = .default) {
        self.router = router
        controller = UIHostingController(rootView: view)
        router.routerController = controller
    }
}

class Router {
    weak var navigationController: UINavigationController?
    weak var routerController: UIViewController?
    var transitioningDelegate: UIViewControllerTransitioningDelegate?
    var adaptivePresentationDelegate: UIAdaptivePresentationControllerDelegate?
    var presentKind = PresentKind.modal
    weak var presentedRouter: Router?

    var isPresented: Bool { presentedController != nil }

    func present(module: Module, animated: Bool = true, sheet: Bool = false) {
        let controller = module.controller

        module.router.presentKind = .modal
        presentedRouter = module.router

        controller.modalTransitionStyle = .coverVertical
        controller.modalPresentationStyle = sheet ? .pageSheet : .fullScreen        

        currentViewController?.present(controller, animated: animated, completion: nil)
    }

    func dismiss(animated: Bool = true, completion: EmptyBlock? = nil) {
        DispatchQueue.main.async {
            if let controller = self.presentedController {
                controller.dismiss(animated: animated, completion: completion)
            } else {
                self.navigationController?.popViewController(animated: animated)
            }
        }
    }

    func dismissByItself(completion: EmptyBlock? = nil) {
        DispatchQueue.main.async {
            switch self.presentKind {
            case .modal:
                self.routerController?.dismiss(animated: true, completion: completion)
            }
        }
    }

    func popToRoot(animated: Bool = true) {
        navigationController?.popToRootViewController(animated: animated)
    }

    private var presentedController: UIViewController? {
        navigationController?.presentedViewController ?? routerController?.presentedViewController
    }

    private var currentViewController: UIViewController? {
        navigationController ?? routerController
    }
}
