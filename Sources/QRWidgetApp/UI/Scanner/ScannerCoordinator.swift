
import AVFoundation
import SwiftUI

extension CodeScannerView {
    @available(macCatalyst 14.0, *)
    public class ScannerCoordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: CodeScannerView
        var codesFound = Set<String>()
        var isScanActive = true
        var shouldVibrateOnSuccess = true
        var didFinishScanning = false
        var lastTime = Date(timeIntervalSince1970: 0)

        init(parent: CodeScannerView) {
            self.parent = parent
        }

        public func reset() {
            codesFound.removeAll()
            didFinishScanning = false
            lastTime = Date(timeIntervalSince1970: 0)
        }

        public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            guard isScanActive else { return }
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard didFinishScanning == false else { return }

                let stringData = readableObject.stringValue
                let descriptor = readableObject.descriptor

                let dataExists = stringData != nil || descriptor != nil
                guard dataExists else {
                    return
                }

                let result = ScanResult(
                    descriptor: descriptor,
                    string: stringData,
                    type: readableObject.type,
                    source: .camera
                )

                switch parent.scanMode {
                case .once:
                    found(result)
                    // make sure we only trigger scan once per use
                    didFinishScanning = true
//
//                case .oncePerCode:
//                    if !codesFound.contains(stringValue) {
//                        codesFound.insert(stringValue)
//                        found(result)
//                    }

                case .continuous:
                    if isPastScanInterval() {
                        found(result)
                    }
                }
            }
        }

        func isPastScanInterval() -> Bool {
            Date().timeIntervalSince(lastTime) >= parent.scanInterval
        }

        func found(_ result: ScanResult) {
            lastTime = Date()

            if shouldVibrateOnSuccess {
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            }

            parent.completion(.success(result))
        }

        func didFail(reason: ScanError) {
            parent.completion(.failure(reason))
        }
    }
}
