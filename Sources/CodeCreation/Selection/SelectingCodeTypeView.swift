
import SwiftUI
import QRWidgetCore
import SwiftUINavigation

class SelectingCodeTypeModel: ObservableObject {
    let allTypes = QRCodeType.allCases

    @Published var destination: Destination?
    enum Destination {
        case creation(CreationCodeModel)
    }
}

struct SelectingCodeTypeView: View {
    @ObservedObject var model: SelectingCodeTypeModel

    var body: some View {
        NavigationView {
            List {
                Section(content: {
                    ForEach(model.allTypes) { type in
                        NavigationLink(
                            unwrapping: self.$model.destination,
                            case: /SelectingCodeTypeModel.Destination.creation,
                            onNavigate: {
                                self.model.destination = $0 ? .creation(CreationCodeModel(type: type)) : nil
                            },
                            destination: { $model in
                                CreationCodeView(model: model)
                            },
                            label: {
                                QRCodeTypeView(type: type)
                            }
                        )
                    }
                }, header: {
                    Text("Select QR type")
                })
            }
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
