//
//  SettingsView.swift
//  QRWidget
//
//  Created by Максим Казаков on 01.11.2021.
//

import SwiftUI

struct SettingsView: View {
    @State var cannotFindExpanded = false
    @State var showPaywall: Bool = false
    @StateObject var viewModel: SettingsViewModel
    @Environment(\.sendAnalyticsEvent) var sendAnalyticsEvent
    
    var body: some View {
        NavigationView {
            List {
                if viewModel.showSubscriptionOffer {
                    SettingActivateView()
                        .onTapGesture {
                            self.showPaywall = true
                        }
                        .frame(maxWidth: .infinity)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .listRowBackground(EmptyView())
                }

                Section(
                    content: {
                        Button(L10n.Settings.contactDeveloper, action: {
                            viewModel.sendEmailToDeveloper()
                        })
                        .foregroundColor(Color.primary)

                        Button(L10n.Settings.writeReview, action: {
                            viewModel.writeReview()
                        })
                        .foregroundColor(Color.primary)
                    },
                    header: {
                        Text(L10n.Settings.general)
                    })

                Section(
                    content: {
                        Toggle(L10n.Settings.vibration, isOn: $viewModel.vibrateOnCodeRecognized)
                    },
                    header: {
                        Text(L10n.Settings.scanner)
                    })

                Section(
                    content: {
                        Button(
                            action: {
                                sendAnalyticsEvent(.howToAddButtonClick, nil)
                                if let url = URL(string: "https://support.apple.com/ru-ru/HT207122") {
                                    UIApplication.shared.open(url)
                                }
                            },
                            label: {
                                Label(
                                    title: {
                                        Text(L10n.Settings.howToAddWidget)
                                            .multilineTextAlignment(.leading)
                                    },
                                    icon: { Image(systemName: "questionmark.circle") }
                                )
                            })
                        .foregroundColor(Color.primary)

                        Button(
                            action: {
                                withAnimation {
                                    cannotFindExpanded = !cannotFindExpanded
                                    sendAnalyticsEvent(.cannotFindWidgetClick, nil)
                                }
                            },
                            label: {
                                VStack {
                                    Label(
                                        title: {
                                            Text(L10n.Settings.BugWithWidget.question)
                                                .multilineTextAlignment(.leading)
                                        },
                                        icon: { Image(systemName: "questionmark.circle") }
                                    )
                                }
                            })
                        .foregroundColor(Color.primary)

                        if self.cannotFindExpanded {
                            Text(L10n.Settings.BugWithWidget.answer)
                                .multilineTextAlignment(.leading)
                        }
                    },
                    header: {
                        Text(L10n.Settings.faq)
                    })

                Section(
                    content: {
                        Button(
                            action: {
                                if let url = URL(string: "https://termify.io/eula/1635320461") {
                                    UIApplication.shared.open(url)
                                }
                            },
                            label: {
                                Text(L10n.Paywall.termsOfUse)
                                    .multilineTextAlignment(.leading)
                            })
                        .foregroundColor(Color.primary)

                        Button(
                            action: {
                                if let url = URL(string: "https://termify.io/privacy-policy/1635319951") {
                                    UIApplication.shared.open(url)
                                }
                            },
                            label: {
                                Text(L10n.Paywall.privacyPolicy)
                                    .multilineTextAlignment(.leading)
                            })
                        .foregroundColor(Color.primary)
                    },
                    header: {
                        Text("")
                    })
            }
            .fullScreenCover(isPresented: $showPaywall) {
                generalAssembly.makePaywallView(sourceScreen: .settings)
            }
            .listStyle(.insetGrouped)
            .navigationTitle(L10n.Settings.title)
        }
        .navigationViewStyle(.stack)
    }
}
