
import SwiftUI
import QRWidgetCore

struct CodeDetailsPresentaionOptions {
    let isPopup: Bool
    let title: String
    let hideCodeImage: Bool

    static let zero = CodeDetailsPresentaionOptions(
        isPopup: false,
        title: L10n.QrDetails.title,
        hideCodeImage: false
    )
}

class DetailsViewModel: ViewModel {

    let codesService: QRCodesService
    let favoritesService: FavoritesService
    let options: CodeDetailsPresentaionOptions
    let sendAnalytics: SendAnalyticsAction

    public init(qrModel: CodeModel,
                qrCodesService: QRCodesService,
                favoritesService: FavoritesService,
                options: CodeDetailsPresentaionOptions,
                sendAnalytics: @escaping SendAnalyticsAction) {
        self.codesService = qrCodesService
        self.favoritesService = favoritesService
        self.options = options
        self.sendAnalytics = sendAnalytics

        self.qrDataType = CodeContent.make(from: qrModel.data.stringPayload)
        self.qrModel = qrModel
        self.qrId = qrModel.id

        super.init()

        // TODO: Remove from init
        setupSubscriptions()
    }

    enum Destination {
        case beautifyQR(BeautifyQRViewModel)
    }

    @Published var showPaywall: Bool = false
    @Published var needToClose = false
    @Published var qrModel: CodeModel
    @Published var isFavorite = false
    @Published var modalDestination: Destination?

    var labelBinding: Binding<String> {
        Binding(get: {
            self.qrModel.label
        }, set: {
            self.qrModel.label = $0
            self.codesService.changeQRLabel(id: self.qrId, newLabel: $0)
        })
    }

    let qrId: UUID
    let qrDataType: CodeContent

    func remove() {
        router.dismissByItself(completion: nil)
        sendAnalytics(.removePass, nil)

        codesService.removeQR(id: qrId)
    }

    func tapChangeAppearance() {
        sendAnalytics(.tapChangeQRAppearance, nil)
        let beautifyViewModel = BeautifyQRViewModel(
            qrModel: qrModel
        )
        beautifyViewModel.onSaveTapped = { [weak self, codesService] in
            codesService.updateQR($0)
            self?.modalDestination = nil
        }
        self.modalDestination = .beautifyQR(beautifyViewModel)
    }

    func tapCancelOnBeautifyScreen() {
        sendAnalytics(.tapCancelChangeQRAppearance, nil)
        modalDestination = nil
    }

    func removeOrAddToFavorites() {
        if isFavorite {
            sendAnalytics(.removeFromFavorites, nil)
            favoritesService.removeFavorite(id: qrId)
        } else {
            sendAnalytics(.addToFavorites, ["source": AnalyticsSource.AddToFavorites.details.rawValue])
            if isProActivated || favoritesService.favorites.value.count < 1 {
                favoritesService.addSavorite(id: qrId)
            } else {
                showPaywall = true
            }
        }
    }

    var favoritesActionTitle: String {
        if isFavorite {
            return L10n.QrDetails.removeFromFavorites
        } else {
            return L10n.QrDetails.addToFavorites
        }
    }

    func makeShareView() -> some View {
        return generalAssembly.makeShareView(parentRouter: router, qrModel: qrModel, source: .details)
    }

    private func setupSubscriptions() {
        codesService.qrCodesPublisher
            .dropFirst()
            .sink(receiveValue: { [weak self] qrCodes in
                guard let self = self else { return }
                if let newQrModel = qrCodes.first(where: { $0.id == self.qrId }),
                   self.qrModel != newQrModel {
                    Logger.debugLog(message: "Update qr model. Label: \(newQrModel.label)")
                    self.qrModel = newQrModel
            }
        })
            .store(in: &cancellableSet)

        favoritesService.favorites
            .map { $0.contains(self.qrId) }
            .sink(receiveValue: { [weak self] in
                self?.isFavorite = $0
            })
            .store(in: &cancellableSet)
    }
}
