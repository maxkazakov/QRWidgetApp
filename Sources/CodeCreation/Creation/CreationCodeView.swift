
import SwiftUI
import QRWidgetCore

final public class CreationCodeModel: ObservableObject {
    
    let type: QRCodeType
    
    public init(type: QRCodeType) {
        self.type = type
    }
}

struct CreationCodeView: View {
    @ObservedObject var model: CreationCodeModel

    var body: some View {
        Text(model.type.title)
    }
}
