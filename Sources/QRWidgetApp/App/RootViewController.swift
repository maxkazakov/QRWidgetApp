//
//  RootViewController.swift
//  QRWidget
//
//  Created by Максим Казаков on 16.01.2022.
//

import UIKit

class RootViewController: UIViewController {

    func set(viewController: UIViewController) {
        children.forEach {
            $0.willMove(toParent: nil)
            $0.view.removeFromSuperview()
            $0.removeFromParent()
        }
        viewController.willMove(toParent: self)
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.view.frame = view.bounds
        view.addSubview(viewController.view)
        addChild(viewController)
        viewController.didMove(toParent: self)
    }
}
