
import SwiftUI
import QRWidgetCore
import SwiftUINavigation
import XCTestDynamicOverlay

public class SelectingCodeTypeModel: ObservableObject {
    public init() {}

    public var onCodeCreatoinFinished: (QRModel) -> Void = unimplemented("SelectingCodeTypeModel.onCodeCreatoinFinished") {
        didSet {
            typeModels.forEach { $0.onCodeCreatoinFinished = self.onCodeCreatoinFinished }
        }
    }

    @Published var typeModels: [QRTypeRowViewModel] = QRCodeType.allCases.map { QRTypeRowViewModel(type: $0) }
    let allTypes = QRCodeType.allCases
}

class QRTypeRowViewModel: ObservableObject, Identifiable {

    public enum Destination: Equatable {
        case creation(CreationCodeModel)
    }

    var id: Int { type.rawValue }
    var onCodeCreatoinFinished: (QRModel) -> Void = unimplemented("QRTypeRowViewModel.onCodeCreatoinFinished")

    let type: QRCodeType
    @Published var destination: Destination? {
        didSet {
            switch destination {
            case let .creation(model):
                model.onCodeCreatoinFinished = onCodeCreatoinFinished
            case .none:
                break
            }
        }
    }

    init(type: QRCodeType, destination: QRTypeRowViewModel.Destination? = nil) {
        self.type = type
        self.destination = destination
    }

    func onSelect() {
        destination = .creation(CreationCodeModel(type: type))
    }
}

struct QRTypeRowView: View {
    @ObservedObject var model: QRTypeRowViewModel

    var body: some View {
        NavigationLink(
            unwrapping: self.$model.destination,
            case: /QRTypeRowViewModel.Destination.creation,
            onNavigate: {
                if $0 { model.onSelect() }
            },
            destination: { $model in
                CreationCodeView(model: model)
            },
            label: {
                QRCodeTypeView(type: model.type)
            }
        )
    }
}

public struct SelectingCodeTypeView: View {

    @ObservedObject var model: SelectingCodeTypeModel

    public init(model: SelectingCodeTypeModel) {
        self.model = model
    }

    public var body: some View {
        NavigationView {
            List {
                Section(content: {
                    ForEach(model.typeModels) { typeModel in
                        QRTypeRowView(model: typeModel)
                    }
                }, header: {
                    Text("Select QR type")
                })
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Code type")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SelectingCodeTypeView_Previews: PreviewProvider {
    static var previews: some View {
        SelectingCodeTypeView(model: SelectingCodeTypeModel())
    }
}
