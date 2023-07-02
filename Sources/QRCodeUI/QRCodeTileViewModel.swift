import SwiftUI
import Combine
import CodeImageGenerator

class QRCodeTileViewModel: ObservableObject {
    @Published var coloredQrImage: UIImage?
    @Published var blackAndWhiteQRImage: UIImage?
    @Published var flipped = false
    @Published var isLoading = false

    private var prevData = CurrentValueSubject<QRCodeTileViewData?, Never>(nil)
    private var cancellableSet: Set<AnyCancellable> = []
    init() {
        prevData
            .compactMap { $0 }
            .removeDuplicates()
            .handleEvents(receiveOutput: { _ in
                self.flipped = false
                self.isLoading = true
            })
            .throttle(for: 0.25, scheduler: RunLoop.main, latest: true)
            .flatMap { [weak self] data -> AnyPublisher<QRGeneratorResult, Never> in
                self?.generateQr(data: data) ?? Empty().eraseToAnyPublisher()
            }
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] result in
                guard let self = self else { return }
                self.blackAndWhiteQRImage = result.blackAndWhiteImage
                self.coloredQrImage = result.coloredImage
                self.isLoading = false
            })
            .store(in: &cancellableSet)
    }

    func update(_ data: QRCodeTileViewData) {
        prevData.send(data)
    }

    private func generateQr(data viewData: QRCodeTileViewData) -> AnyPublisher<QRGeneratorResult, Never> {
        Deferred {
            Future<QRGeneratorResult, Never> { promise in
                var newQrColoredImage: UIImage?
                if viewData.foreground != CGColor.qr.defaultForeground || viewData.background != CGColor.qr.defaultBackground {
                    newQrColoredImage = CodeGenerator.shared.generateQRCode(
                        from: viewData.data,
                        foreground: viewData.foreground,
                        background: viewData.background,
                        errorCorrectionLevel: viewData.errorCorrectionLevel.rawValue,
                        codeType: viewData.codeType
                    )
                }
                let newBlackAndWhiteQrImage = CodeGenerator.shared.generateQRCode(
                    from: viewData.data,
                    foreground: CGColor.qr.defaultForeground,
                    background: CGColor.qr.defaultBackground,
                    errorCorrectionLevel: viewData.errorCorrectionLevel.rawValue,
                    codeType: viewData.codeType
                )!
                let result = QRGeneratorResult(blackAndWhiteImage: newBlackAndWhiteQrImage, coloredImage: newQrColoredImage ?? newBlackAndWhiteQrImage)
                promise(.success(result))
            }
        }
        .subscribe(on: DispatchQueue.global(qos: .userInitiated))
        .eraseToAnyPublisher()
    }
}

struct QRGeneratorResult {
    let blackAndWhiteImage: UIImage
    let coloredImage: UIImage
}
