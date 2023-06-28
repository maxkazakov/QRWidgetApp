
import PassKit
import Combine
import QRWidgetCore

public typealias PassSerialNumber = String

struct WalletServiceError: Error {}

class WalletService {

    private let queue = DispatchQueue(label: "WalletQueue", qos: .background)
    private let walletPassEnvironment: WalletPassEnvironment
    private let passLibrary = PKPassLibrary()
    private let userDefaults: UserDefaultsStorage
    private let analyticsEnvironment: AnalyticsEnvironment

    init(userDefaults: UserDefaultsStorage, walletPassEnvironment: WalletPassEnvironment, analyticsEnvironment: AnalyticsEnvironment) {
        self.walletPassEnvironment = walletPassEnvironment
        self.userDefaults = userDefaults
        self.analyticsEnvironment = analyticsEnvironment
    }

    private(set) var allWalletPasses: [UUID: PassSerialNumber] = [:] {
        didSet {
            analyticsEnvironment.updateWalletPassCount(passCount: allWalletPasses.count)
            userDefaults.walletPassesByQRCodeId = allWalletPasses
        }
    }

    func createPass(code: CodeModel) -> AnyPublisher<PKPass, Error> {
        let serialNumber = allWalletPasses[code.id] ?? UUID().uuidString
        let data: WalletPassInputParams.DataType
        if let stringPayload = code.data.stringPayload {
            data = .string(stringPayload)
        } else {
            return Fail(error: WalletServiceError()).eraseToAnyPublisher()
        }
        return walletPassEnvironment.createPass(
            WalletPassInputParams(
                serialNumber: serialNumber,
                data: data,
                label: code.label,
                codeType: code.type
            )
        )
    }

    func loadAndValidatePasses() {
        let allWalletPassesFromStorage = userDefaults.walletPassesByQRCodeId
        let validatedPasses = allWalletPassesFromStorage.filter { _, serialNumber in
            passLibrary.pass(withPassTypeIdentifier: walletPassEnvironment.passIdentifier(), serialNumber: serialNumber) != nil
        }
        self.allWalletPasses = validatedPasses
    }

    func checkPassCreated(_ pass: PKPass, qrCode: CodeModel) -> Bool {
        return passLibrary.containsPass(pass)
    }

    func addPass(qrId: UUID, passId: String) {
        allWalletPasses[qrId] = passId
    }

    func deletePass(by id: UUID) {
        guard let serialNumber = allWalletPasses[id] else {
            return
        }
        let passLibrary = PKPassLibrary()
        if let pass = passLibrary.pass(withPassTypeIdentifier: walletPassEnvironment.passIdentifier(), serialNumber: serialNumber) {
            passLibrary.removePass(pass)
        }
        self.allWalletPasses.removeValue(forKey: id)
    }
}
