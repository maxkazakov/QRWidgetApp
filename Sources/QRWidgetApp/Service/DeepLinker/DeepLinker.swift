//
//  DeepLinker.swift
//  QRWidget
//
//  Created by Максим Казаков on 23.10.2021.
//

import Foundation
import SwiftUI
import Combine

extension URL {
    static let appScheme = "qrwidget"
}

public class Deeplinker {
    enum Deeplink: Equatable {
        case qr(id: UUID)
    }

    private let starter: Starter
    private let qrCodesService: QRCodesService
    private let sendAnalytics: SendAnalyticsAction
    private var cancellableSet = Set<AnyCancellable>()

    init(starter: Starter, qrCodesService: QRCodesService, sendAnalytics: @escaping SendAnalyticsAction) {
        self.starter = starter
        self.sendAnalytics = sendAnalytics
        self.qrCodesService = qrCodesService
    }

    public func handle(url: URL) {
        Logger.debugLog(message: "Deeplinker: handle url: \(url)")
        guard url.scheme == URL.appScheme else { return }
        var deeplink: Deeplink?

        if let host = url.host, let id = UUID(uuidString: host) {
            sendAnalytics(.openWidgetDeeplink, nil)
            deeplink = .qr(id: id)
        }

        guard let deeplink = deeplink else {
            return
        }

        // Wait for app is ready and then activate deeplink
        starter.isAppStartedPublisher
            .filter { $0 }
            .map { _ in }
            .sink(receiveValue: {
                self.activateDeeplink(deeplink)
            })
            .store(in: &cancellableSet)
    }

    private func activateDeeplink(_ deeplink: Deeplink) {
        Logger.debugLog(message: "Deeplinker: activate deeplink: \(deeplink)")

        switch deeplink {
        case .qr(let id):
            guard let qrModel = qrCodesService.getQR(id: id) else {
                return
            }
            generalAssembly.appRouter.route(route: .details(qrModel))
        }
    }
}
