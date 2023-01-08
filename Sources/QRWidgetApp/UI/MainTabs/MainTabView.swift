
import SwiftUI

enum Tab: Int, Identifiable {
    var id: Int { self.rawValue }

    case scan = 1
    case history = 2
    case settings = 3
}

struct MainTabView: View {
    @StateObject var viewModel: MainTabViewModel

    var body: some View {
        TabView(selection: $viewModel.currentTab) {
            generalAssembly.makeQRCodeScannerView()
                .tabItem {
                    Label(L10n.Tabs.scan, systemImage: "qrcode.viewfinder")
                }
                .tag(Tab.scan)

            NavigationView {
                AllCodesView(viewModel: viewModel.allCodesTabModel)
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label(L10n.Tabs.history, systemImage: "list.bullet")
            }
            .tag(Tab.history)

            generalAssembly.makeSettingsModule()
                .tabItem {
                    Label(L10n.Tabs.settings, systemImage: "gearshape")
                }
                .tag(Tab.settings)
        }
        .accentColor(.blue)
        .tabViewStyle(.automatic)
    }
}
