
import SwiftUI

enum Tab: Int, Identifiable {
    var id: Int { self.rawValue }
    case create = 1
    case scan = 2
    case history = 3
    case settings = 4
}

struct MainTabView: View {
    @StateObject var viewModel: MainTabViewModel

    var body: some View {
        TabView(selection: $viewModel.currentTab) {
            CodeCreationFlowView()
                .environmentObject(viewModel.codeCreationModel)
                .tabItem {
                    Label("Create QR", systemImage: "plus.circle")
                }
                .tag(Tab.create)

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
        .fullScreenCover(isPresented: $viewModel.presentingPaywall) {
            generalAssembly.makePaywallView(sourceScreen: .randomlyOnStart)
        }
        .onAppear {
            viewModel.onAppear()
        }
        .accentColor(.blue)
        .tabViewStyle(.automatic)
    }
}
