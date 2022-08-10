//
//  ShareMenuViewModel.swift
//  QRWidget
//
//  Created by Максим Казаков on 23.04.2022.
//

import SwiftUI
import Combine
import QRWidgetCore
import QRGenerator

class ShareMenuViewModel: ViewModel {

    private let sendAnalytics: SendAnalyticsAction
    private let source: AnalyticsSource.Share

    init(source: AnalyticsSource.Share, sendAnalytics: @escaping SendAnalyticsAction) {
        self.source = source
        self.sendAnalytics = sendAnalytics
    }

    func shareAsText(_ qrModel: QRModel) {
        sendAnalytics(.tapShareAsString, ["source": source.rawValue])
        let text = qrModel.qrData
        self.share(items: [text])
    }

    func shareAsImage(_ qrModel: QRModel) {
        sendAnalytics(.tapShareAsImage, ["source": source.rawValue])
        guard let image = QRCodeGenerator.shared.generateQRCode(from: qrModel, useCustomColorsIfPossible: false) else {
            return
        }
        self.share(items: [image])
    }

    func trackTapShare() {
        sendAnalytics(.tapShare, ["source": source.rawValue])
    }

    @discardableResult
    private func share( items: [Any], excludedActivityTypes: [UIActivity.ActivityType]? = nil) -> Bool {
        guard let source = UIApplication.shared.windows.last?.rootViewController else {
            return false
        }
        let shareViewController = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        shareViewController.excludedActivityTypes = excludedActivityTypes
        shareViewController.popoverPresentationController?.sourceView = source.view
        router.routerController?.present(shareViewController, animated: true, completion: nil)
        return true
    }
}
