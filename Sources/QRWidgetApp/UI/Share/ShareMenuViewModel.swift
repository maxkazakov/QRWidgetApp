
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

    func shareAsImage(_ codeModel: CodeModel) {
        do {
            sendAnalytics(.tapShareAsImage, ["source": source.rawValue])

            let targetURL = makeTempFilename(for: codeModel, extenstion: "jpeg")
            if FileManager.default.fileExists(atPath: targetURL.path) {
                try FileManager.default.removeItem(atPath: targetURL.path)
            }
            guard let image = codeGenerator.generateCodeFromModel(codeModel, true),
                  let jpegImageData = image.jpegData(compressionQuality: 1.0)
            else {
                return
            }
            try jpegImageData.write(to: targetURL)
            share(items: [targetURL as NSURL])
        }  catch {
            print("Failed to share JPEG file. Error = \(error)")
        }
    }

    func shareAsPdf(_ codeModel: CodeModel) {
        sendAnalytics(.tapShareAsPdf, ["source": source.rawValue])
        do {
            let targetURL = makeTempFilename(for: codeModel, extenstion: "pdf")
            if FileManager.default.fileExists(atPath: targetURL.path) {
                try FileManager.default.removeItem(atPath: targetURL.path)
            }
            guard let image = codeGenerator.generateCodeFromModel(codeModel, true) else {
                return
            }
            let imageBounds = CGRect(origin: .zero, size: .init(width: 300, height: 300))
            let pdfRenderer = UIGraphicsPDFRenderer(bounds: imageBounds)
            try pdfRenderer.writePDF(to: targetURL) { context in
                context.beginPage()
                image.draw(in: imageBounds)
            }
            share(items: [targetURL as NSURL])
        } catch {
            print("Failed to share PDF file. Error = \(error)")
        }
    }

    private func makeTempFilename(for codeModel: CodeModel, extenstion: String) -> URL {
        let tempDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let fileName: String
        if !codeModel.label.isEmpty {
            fileName = codeModel.label
        } else {
            fileName = codeModel.id.uuidString
        }
        let targetURL = tempDirectoryURL.appendingPathComponent(fileName).appendingPathExtension(extenstion)
        return targetURL
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
