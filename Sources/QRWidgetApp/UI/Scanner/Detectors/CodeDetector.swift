import Vision
import UIKit
import AVFoundation

struct CodeDetectorResult {
    let codeType: AVMetadataObject.ObjectType
    let descriptor: CIBarcodeDescriptor?
    let stringPayload: String?
}

class CodeDetector {

    struct CodeDetectorError: Error { }

    func find(image: UIImage) async throws -> CodeDetectorResult {
        try await withCheckedThrowingContinuation { continuation in
            guard let cgImage = image.cgImage else {
                continuation.resume(throwing: CodeDetectorError())
                return
            }
            let orientation = CGImagePropertyOrientation(image.imageOrientation)
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])
            let vnRequests = [vnBarCodeDetectionRequest(continuation: continuation)]
            do {
                try requestHandler.perform(vnRequests)
            } catch let error as NSError {
                continuation.resume(throwing: error)
            }
        }
    }

    func vnBarCodeDetectionRequest(continuation: CheckedContinuation<CodeDetectorResult, Error>) -> VNDetectBarcodesRequest{
        let request = VNDetectBarcodesRequest { (request,error) in
            if let error = error as NSError? {
                print("Error in detecting - \(error)")
                continuation.resume(throwing: error)
                return
            }
            else {
                guard let observations = request.results as? [VNBarcodeObservation],
                      let observation = observations.max(by: { $0.confidence < $1.confidence }),
                      let avCodeType = self.mapToAVCodeType(observation.symbology)
                else {
                    continuation.resume(throwing: CodeDetectorError())
                    return
                }

                let barcodeDescriptor = observation.barcodeDescriptor
                let stringPayload = observation.payloadStringValue
                print("Reading from photo. Stirng = ", stringPayload, ", descriptor = ", barcodeDescriptor)
                let dataExist = stringPayload != nil || barcodeDescriptor != nil
                guard dataExist else {
                    continuation.resume(throwing: CodeDetectorError())
                    return
                }

                let result = CodeDetectorResult(
                    codeType: avCodeType,
                    descriptor: barcodeDescriptor,
                    stringPayload: observation.payloadStringValue
                )
                continuation.resume(returning: result)
            }
        }
        return request
    }

    private func mapToAVCodeType(_ barcodeSymbology: VNBarcodeSymbology) -> AVMetadataObject.ObjectType? {
        switch barcodeSymbology {
        case .aztec:
            return .aztec
        case .qr:
            return .qr
        case .ean13:
            return .ean13
        case .ean8:
            return .ean8
        case .code128:
            return .code128
        case .code39:
            return .code39
        case .pdf417:
            return .pdf417
        default:
            return nil
        }
    }
}

extension CGImagePropertyOrientation {
    /**
     Converts a `UIImageOrientation` to a corresponding
     `CGImagePropertyOrientation`. The cases for each
     orientation are represented by different raw values.

     - Tag: ConvertOrientation
     */
    init(_ orientation: UIImage.Orientation) {
        switch orientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        @unknown default:
            self = .up
        }
    }
}
