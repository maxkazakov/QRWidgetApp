
import SwiftUI
import Combine

protocol ViewModelProtocol: ObservableObject {
    var router: Router { get }
    var parentRouter: Router? { get }

    func route(_ route: Route)

    func close()
    func close(completion: EmptyBlock?)
}


class ViewModel: ViewModelProtocol {

    @Published var isProActivated: Bool = false

    init() {
        let paymentEnvironment = generalAssembly.appEnvironment.paymentEnvironment
        paymentEnvironment.proActivatedPublisher()
            .sink(receiveValue: { [weak self] isActivated in
                self?.isProActivated = isActivated
            })
            .store(in: &cancellableSet)
    }

    func close() {
        router.dismissByItself()
    }

    func close(completion: EmptyBlock?) {
        router.dismissByItself(completion: completion)
    }

    var router = Router()
    var parentRouter: Router?

    var cancellableSet = Set<AnyCancellable>()

    func route(_ route: Route) {
        generalAssembly.appRouter.route(parentrRouter: router, route: route)
    }

    /// fix for iOS <14.5
    /// Issue #71816443 https://developer.apple.com/documentation/ios-ipados-release-notes/ios-ipados-14_5-release-notes
    func fixObjectWillChange(_ subObjectWillChange: ObservableObjectPublisher) {
        if #available(iOS 14.5, *) {} else {
            subObjectWillChange
                .sink { [weak self] in self?.objectWillChange.send() }
                .store(in: &cancellableSet)
        }
    }
}
