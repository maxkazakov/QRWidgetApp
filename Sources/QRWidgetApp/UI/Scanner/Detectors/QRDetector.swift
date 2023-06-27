import Vision
import UIKit

class QRDetector {
    struct QRDetectorError: Error {

    }

    func find(image: UIImage) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])!
            let ciImage = CIImage(image: image)!
            var qrCodePayload = ""

            let features = detector.features(in: ciImage)

            for feature in features as! [CIQRCodeFeature] {
                qrCodePayload += feature.messageString!
            }

            if qrCodePayload.isEmpty {
                continuation.resume(throwing: QRDetectorError())
            } else {
                continuation.resume(returning: qrCodePayload)
            }
        }
    }
}
