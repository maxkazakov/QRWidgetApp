
import SwiftUI
import QRWidgetCore
import SwiftUINavigation

public class SelectingCodeTypeModel: ObservableObject {
    public init(destination: SelectingCodeTypeModel.Destination? = nil) {
        self.destination = destination
    }

    let allTypes = QRCodeType.allCases

    @Published var destination: Destination?
    public enum Destination: Equatable {
        case creation(CreationCodeModel)
    }
}

public struct SelectingCodeTypeView: View {
    public init(model: SelectingCodeTypeModel) {
        self.model = model
    }

    @ObservedObject var model: SelectingCodeTypeModel

    @State var isActive: Bool = false

    public var body: some View {
        NavigationView {            
            List {
                Section(content: {
                    ForEach(model.allTypes) { type in
                        Button(action: {
                            model.destination = .creation(CreationCodeModel(type: type))
                        }, label: {
                            QRCodeTypeView(type: type)
                        })
                    }
                }, header: {
                    Text("Select QR type")
                })
            }
            .background(
                NavigationLink(
                    unwrapping: self.$model.destination,
                    case: /SelectingCodeTypeModel.Destination.creation,
                    onNavigate: {
                        if $0 == false {
                            self.model.destination = nil
                        }
                    },
                    destination: { $model in
                        CreationCodeView(model: model)
                    },
                    label: { EmptyView() }
                )
            )
            .navigationTitle("New code")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SelectingCodeTypeView_Previews: PreviewProvider {
    static var previews: some View {
        SelectingCodeTypeView(model: SelectingCodeTypeModel())
    }
}
