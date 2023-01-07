
import UIKit
import SwiftUI
import QRWidgetCore

// Entry point

public class QRWidgetApplication {
    public init() {}

    public func start(with appEnvironment: AppEnvironment, window: UIWindow) {
        generalAssembly.appEnvironment = appEnvironment
        generalAssembly.starter.start(window: window)
    }

    public func handleDeeplink(url: URL) {
        generalAssembly.deeplinker.handle(url: url)
    }

    public func applicationWillEnterForeground() {
        generalAssembly.userDefaultsStorage.openAppCounter += 1
    }
}

