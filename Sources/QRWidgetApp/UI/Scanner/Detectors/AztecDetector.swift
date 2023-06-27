import Vision
import UIKit

class AztecDetector {
    struct AztecCodeDetectorError: Error {

    }

    func find(image: UIImage) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            guard let cgImage = image.cgImage else {
                continuation.resume(throwing: AztecCodeDetectorError())
                return
            }
            let orientation = CGImagePropertyOrientation(image.imageOrientation)
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])
            let vnRequests = [vnBarCodeDetectionRequest(continuation: continuation)]
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try requestHandler.perform(vnRequests)
                } catch let error as NSError {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func vnBarCodeDetectionRequest(continuation: CheckedContinuation<String, Error>) -> VNDetectBarcodesRequest{
        let request = VNDetectBarcodesRequest { (request,error) in
            if let error = error as NSError? {
                print("Error in detecting - \(error)")
                continuation.resume(throwing: error)
                return
            }
            else {
                guard let observations = request.results as? [VNBarcodeObservation],
                      let observation = observations.first(where: { $0.confidence == 1.0 }),
                      let payload = observation.payloadStringValue
                else {
                    continuation.resume(throwing: AztecCodeDetectorError())
                    return
                }
                continuation.resume(returning: payload)
            }
        }
        return request
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
