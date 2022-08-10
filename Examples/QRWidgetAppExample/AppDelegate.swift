//
//  AppDelegate.swift
//  QRWidgetAppExample
//
//  Created by Максим Казаков on 10.08.2022.
//

import Foundation
import UIKit
import QRWidgetApp
import Combine

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var qrWidgetApplication = QRWidgetApplication()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow()

        let analyticsEnvironment = AnalyticsEnvironment.unimplemented
        var purchasesEnvironment = PurchasesEnvironment.unimplemented
        let walletPassEnvironment = WalletPassEnvironment.unimplemented

        purchasesEnvironment.offerings = {
            let products = [QRProduct(id: "1", isPopular: true, title: "Forever", priceInfo: "$15", type: .oneTime, purchase: {
                Fail(error: PurchasesError.custom("Purchase func is not implemented")).eraseToAnyPublisher()
            })]
            return Just(products).setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        let appEnviroment = AppEnvironment(
            analyticsEnvironment: analyticsEnvironment,
            paymentEnvironment: purchasesEnvironment,
            walletPassEnvironment: walletPassEnvironment,
            debugLog: { message in Swift.print(message) }
        )

        qrWidgetApplication.start(with: appEnviroment, window: window)
        self.window = window
        return true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        qrWidgetApplication.applicationWillEnterForeground()
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        qrWidgetApplication.handleDeeplink(url: url)
        return true
    }
}
