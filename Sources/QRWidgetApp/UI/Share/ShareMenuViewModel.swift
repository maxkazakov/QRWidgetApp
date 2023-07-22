
import SwiftUI
import Combine
import QRWidgetCore
import CodeImageGenerator
import Dependencies

class ShareMenuViewModel: ViewModel {

    @Dependency(\.codeGenerator) var codeGenerator
    private let sendAnalytics: SendAnalyticsAction
    private let source: AnalyticsSource.Share

    init(source: AnalyticsSource.Share, sendAnalytics: @escaping SendAnalyticsAction) {
        self.source = source
        self.sendAnalytics = sendAnalytics
    }

    func shareAsText(_ qrModel: CodeModel) {
        guard let text = qrModel.data.stringPayload else {
            return
        }
        sendAnalytics(.tapShareAsString, ["source": source.rawValue])
        self.share(items: [text])
    }

    func shareAsImage(_ qrModel: CodeModel) {
        do {
            sendAnalytics(.tapShareAsImage, ["source": source.rawValue])
            let tempDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            let fileName: String
            if !qrModel.label.isEmpty {
                fileName = qrModel.label
            } else {
                fileName = qrModel.id.uuidString
            }
            let targetURL = tempDirectoryURL.appendingPathComponent(fileName).appendingPathExtension("jpeg")
            if FileManager.default.fileExists(atPath: targetURL.path) {
                try FileManager.default.removeItem(atPath: targetURL.path)
            }
            guard let image = codeGenerator.generateCodeFromModel(qrModel, true),
                  let jpegImageData = image.jpegData(compressionQuality: 1.0)
            else {
                return
            }
            try jpegImageData.write(to: targetURL)
            share(items: [targetURL as NSURL])
        }  catch {
            print("Failed to share file. Error = \(error)")
        }
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
