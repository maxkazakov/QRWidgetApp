import Foundation
import WatchConnectivity
import Combine
import QRWidgetCore

public final class WatchManager: NSObject {

    var favoriteCodesPublisher: AnyPublisher<[CodeTransferData], Never>!

    private let decoder = JSONDecoder()
    private var cancellableSet = Set<AnyCancellable>()

    private var favoriteCodes = PassthroughSubject<[CodeTransferData], Never>()
    private var sessionStatus = PassthroughSubject<WCSessionActivationState, Never>()

    func startSession() {
        favoriteCodesPublisher = sessionStatus
            .filter { $0 == .activated }
            .combineLatest(favoriteCodes)
            .map { $0.1 }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()

        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
}

extension WatchManager: WCSessionDelegate {
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("WatchManager. activationDidCompleteWith activationState: \(activationState) error: \(String(describing: error))")
        sessionStatus.send(activationState)
        switch activationState {
        case .activated:
            print("WatchManager. Current context start parsing")
            let codes = (try? decodeContext(session.receivedApplicationContext)) ?? []
            DispatchQueue.main.async { self.favoriteCodes.send(codes) }
            print("WatchManager. Current context finished parsing. Count: \(codes.count)")
        default:
            break
        }
    }

    public func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("WatchManager. didReceiveApplicationContext. Start")
        do {
            let sortedCodes = try decodeContext(applicationContext)
            print("WatchManager. didReceiveApplicationContext. Data Parsed. Items count: \(sortedCodes.count)")
            DispatchQueue.main.async { self.favoriteCodes.send(sortedCodes) }
        }
        catch {
            print("WatchManager. didReceiveApplicationContext error: \(error)")
        }
    }

    private func decodeContext(_ dict: [String: Any]) throws -> [CodeTransferData] {
        guard let data = dict[codesKey] as? Data else {
            return []
        }
        print("WatchManager. didReceiveApplicationContext. Data Received. Bytes: \(ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .binary))")
        let codes = try decoder.decode([CodeTransferData].self, from: data)
        let sortedCodes = codes.sorted(by: { $0.orderIdx < $1.orderIdx })
        return sortedCodes
    }
}
