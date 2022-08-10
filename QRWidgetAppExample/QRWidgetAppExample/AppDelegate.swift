//
//  AppDelegate.swift
//  QRWidgetAppExample
//
//  Created by Максим Казаков on 10.08.2022.
//

import Foundation
import UIKit
import QRWidgetApp

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var qrWidgetApplication = QRWidgetApplication()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow()

        let analyticsEnvironment = AnalyticsEnvironment.unimplemented
        let purchasesEnvironment = PurchasesEnvironment.unimplemented
        let walletPassEnvironment = WalletPassEnvironment.unimplemented

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
