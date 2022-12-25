//
//  BeautifyQRCode.swift
//  QRWidget
//
//  Created by Максим Казаков on 04.01.2022.
//

import SwiftUI
import QRWidgetCore
import QRCodeUI

struct BeautifyQRView: View {
    @StateObject var viewModel: BeautifyQRViewModel

    var body: some View {
        content
    }

    @ViewBuilder
    var content: some View {
        NavigationView {
            ZStack {
                Form {
                    Section {
                        HStack {
                            Spacer()
                            QRCodeTileView(                              
                                qrData: viewModel.qrModel.qrData,
                                foreground: viewModel.foregroundColor,
                                background: viewModel.backgroundColor,
                                errorCorrectionLevel: viewModel.errorCorrectionLevel)
                            Spacer()
                        }
                        .padding(.vertical, 16)
                    }

                    Section(
                        content: {
                            ColorPicker(L10n.ChangeAppearance.foregroundColor, selection: $viewModel.foregroundColor, supportsOpacity: false)
                            ColorPicker(L10n.ChangeAppearance.backgroundColor, selection: $viewModel.backgroundColor, supportsOpacity: false)
                        },
                        header: {
                            Label(
                                title: { Text(L10n.ChangeAppearance.colors) },
                                icon: { lockView }
                            )
                        })

                    Section(
                        content: {
                            Picker("", selection: $viewModel.errorCorrectionLevel) {
                                ForEach(ErrorCorrection.allCases, id: \.rawValue) {
                                    Text($0.title).tag($0)
                                }
                            }
                            .pickerStyle(.segmented)
                        },
                        header: {
                            Label(
                                title: { Text(L10n.ChangeAppearance.errorCorrectionLevel) },
                                icon: { lockView }
                            )
                        },
                        footer: {
                            Spacer().frame(height: 60)
                        }
                    )
                }
                .listStyle(.insetGrouped)
                .navigationBarItems(
                    leading: Button(L10n.cancel, action: {
                        viewModel.cancel()
                    })
                        .foregroundColor(Color.primaryColor)
                )

                VStack {
                    Spacer()
                    Button(action: {
                        viewModel.save()
                    }, label: {
                        Text(L10n.save)
                            .fontWeight(.semibold)
                            .font(.body)
                            .padding(.vertical, 16)
                            .frame(height: 50)
                    })
                        .buttonStyle(MainButtonStyle())
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
            .navigationTitle(L10n.ChangeAppearance.title)
            .navigationBarTitleDisplayMode(.inline)
        }
        .fullScreenCover(isPresented: $viewModel.showPaywall) {
            generalAssembly.makePaywallView(sourceScreen: .changeAppearance)
        }
        .navigationViewStyle(.stack)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var lockView: some View {
        if viewModel.isProActivated {
            EmptyView()
        } else {
            Image(systemName: "lock.fill")
        }
    }
}
