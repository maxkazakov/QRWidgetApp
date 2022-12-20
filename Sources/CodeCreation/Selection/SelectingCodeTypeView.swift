
import SwiftUI
import QRWidgetCore
import SwiftUINavigation

class SelectingCodeTypeModel: ObservableObject {
    let allTypes = QRCodeType.allCases

    @Published var destination: Destination?
    enum Destination {
        case creation(QRCodeType)
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
                                self.model.destination = $0 ? .creation(type) : nil
                            },
                            destination: { type in
                                CreationCodeView(model: CreationCodeModel(type: type.wrappedValue))
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
            .toolbar {
                ToolbarItemGroup() {
                    Button("First") {
                        print("Pressed")
                    }
                }
            }
        }
    }
}

struct SelectingCodeTypeView_Previews: PreviewProvider {
    static var previews: some View {
        SelectingCodeTypeView(model: SelectingCodeTypeModel())
    }
}
