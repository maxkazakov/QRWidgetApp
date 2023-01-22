import Combine
import Foundation
import UIKit

struct CodeUIModel: Identifiable {
    let id: UUID
    let image: UIImage
    let label: String
}

class QRCodesTabsViewModel: ObservableObject {

    @Published var codes: [CodeUIModel] = []
    @Published var loading = true
    private let watchManager = WatchManager()
    private var cancellableSet = Set<AnyCancellable>()

    var wasAppeared = false
    func onAppear() {
        guard !wasAppeared else { return }
        defer { wasAppeared = true }

        #if targetEnvironment(simulator)
        self.loading = false
        let image = UIImage(named: "qrForScreenshot", in: Bundle.module, with: nil)!
        self.codes = [CodeUIModel(id: UUID(), image: image, label: "Cinema ticket")]
        #else
        startWatchManager()
        #endif
    }

    private func startWatchManager() {
        watchManager.startSession()

        watchManager.favoriteCodesPublisher
            .sink(receiveValue: {
                print("QRCodesTabsViewModel. Sink. Count: \($0.count)")
                self.loading = false
                self.codes = $0.compactMap {
                    guard let image = UIImage(data: $0.imageData) else {
                        return nil
                    }
                    return CodeUIModel(id: $0.id, image: image, label: $0.label)
                }
            })
            .store(in: &cancellableSet)
    }
}
