//
//  MainTabView.swift
//  QRWidget
//
//  Created by Максим Казаков on 21.02.2022.
//

import SwiftUI

enum Tab: Int, Identifiable {
    var id: Int { self.rawValue }

    case favorites = 1
    case scan = 2
    case history = 3
    case settings = 4
}

struct MainTabView: View {
    @StateObject var viewModel: MainTabViewModel

    var body: some View {
        TabView(selection: $viewModel.currentTab) {
            generalAssembly.makeQRCodePagesView()
                .tabItem {
                    Label(L10n.Tabs.favorites, systemImage: "star.fill")
                }
                .tag(Tab.favorites)

            generalAssembly.makeQRCodeScannerView()
                .tabItem {
                    Label(L10n.Tabs.scan, systemImage: "qrcode.viewfinder")
                }
                .tag(Tab.scan)

            NavigationView {
                generalAssembly.makeHistoryView()
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
        .colorScheme(viewModel.currentTab == .favorites ? .dark : .light)
    }
}
