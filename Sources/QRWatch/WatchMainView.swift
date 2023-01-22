
import SwiftUI

public struct WatchMainView: View {
    public init() {}

    @StateObject var viewModel = QRCodesTabsViewModel()

    public var body: some View {
        ZStack {
            if viewModel.loading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .gray))
            } else if viewModel.codes.isEmpty {
                Text(L10n.Placeholder.text)
            } else {
                QRTabsView(codes: viewModel.codes)
            }
        }
        .onAppear(perform: {
            viewModel.onAppear()
        })
    }
}

struct QRTabsView: View {

    let codes: [CodeUIModel]

    var body: some View {
        TabView {
            ForEach(codes) { code in
                ZStack {
                    Color.white.ignoresSafeArea()
                    VStack {
                        if !code.label.isEmpty {
                            Text(code.label).foregroundColor(.black)
                                .font(.caption2)
                                .lineLimit(2)
                                .padding(.horizontal, 8)
                                .multilineTextAlignment(.center)
                        }
                        Image(uiImage: code.image)
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()
                            .clipped()
                    }
                }
                .ignoresSafeArea(.all, edges: .all)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
    }
}

struct QRTabsView_Previews: PreviewProvider {
    static var previews: some View {
//        Text("Some")
        QRTabsView(
            codes: [
                CodeUIModel(
                    id: UUID(),
                    image: UIImage(named: "qrForScreenshot", in: Bundle.module, with: nil)!,
                    label: "Movie ticket")
            ]
        )
//        QRTabsView(codes: [CodeUIModel(id: UUID(), image: UIImage(named: "qrtest")!, label: "")])
    }
}
