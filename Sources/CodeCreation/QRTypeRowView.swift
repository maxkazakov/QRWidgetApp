//
//import SwiftUI
//import QRWidgetCore
//import SwiftUINavigation
//import XCTestDynamicOverlay
//
//class QRTypeRowViewModel: ObservableObject, Identifiable {
//
//    public enum Destination {
//        case creation(QRCodeType)
//    }
//
//    var id: Int { type.rawValue }
//
//    let type: QRCodeType
//    @Published var destination: Destination?
//
//    init(type: QRCodeType, destination: QRTypeRowViewModel.Destination? = nil) {
//        self.type = type
//        self.destination = destination
//    }
//
//    func onSelect() {
//        destination = .creation(type)
//    }
//}
//
//struct QRTypeRowView: View {
//    @ObservedObject var model: QRTypeRowViewModel
//
//    var body: some View {
//        NavigationLink(
//            unwrapping: self.$model.destination,
//            case: /QRTypeRowViewModel.Destination.creation,
//            onNavigate: {
//                if $0 { model.onSelect() }
//            },
//            destination: { _ in
//                CreationCodeView()
//            },
//            label: {
//                QRCodeTypeView(type: model.type)
//            }
//        )
//    }
//}
