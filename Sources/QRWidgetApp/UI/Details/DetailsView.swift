//
//  DetailsView.swift
//  QRWidget
//
//  Created by Максим Казаков on 21.04.2022.
//

import SwiftUI

struct DetailsView: View {
    @StateObject var viewModel: DetailsViewModel
    @State var removeConfirmation: Bool = false

    var body: some View {
        content
    }

    @ViewBuilder
    var content: some View {
        Form {
            if !viewModel.options.hideCodeImage {
                Section(content:  {
                    VStack {
                        HStack {
                            Spacer()
                            QRCodeTileView(model: viewModel.qrModel,
                                           proVersionActivated: viewModel.isProActivated)
                            Spacer()
                        }
                        .padding(.vertical, 12)
                    }
                })
            }

            Section(
                content: {
                    QRCodeView(type: viewModel.qrDataType)
                        .padding(.vertical, 8)
                    CustomTestField(placeholder: L10n.QrDetails.Name.placeholder, text: viewModel.labelBinding)
                    Button(action: {
                        viewModel.tapChangeAppearance()
                    }, label: {
                        HStack {
                            Text(L10n.ChangeAppearance.buttonTitle)
                            Spacer()
                        }
                    })
                    .foregroundColor(Color.primaryColor)
                }
            )

            Section(
                content: {
                    HStack {
                        Spacer()
                        generalAssembly.makeAddToWalletButton(qrModel: viewModel.qrModel)
                        Spacer()
                    }
                    .padding(.vertical, 12)
                },
                header: {
                    Label(
                        title: { Text(L10n.QrDetails.appleWalletPass) },
                        icon: { lockView }
                    )
                })

            Section(
                content: {
                    Button(action: {
                        viewModel.removeOrAddToFavorites()
                    }, label: {
                        HStack {
                            Text(viewModel.favoritesActionTitle)
                            Spacer()
                        }
                    })
                    .foregroundColor(Color.primaryColor)

                    Button(action: {
                        removeConfirmation = true
                    }, label: {
                        HStack {
                            Text(L10n.DeleteQr.buttonTitle)
                                .foregroundColor(.red)
                            Spacer()
                        }
                    })
                }
            )
        }
        .listStyle(.insetGrouped)
        .navigationBarItems(trailing: shareButton)
        .navigationTitle(viewModel.options.title)
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $viewModel.showPaywall) {
            generalAssembly.makePaywallView(sourceScreen: .details)
        }
        .alert(isPresented: self.$removeConfirmation, content: {
            Alert(
                title: Text(L10n.DeleteQr.caution),
                primaryButton: .cancel(),
                secondaryButton: .destructive(Text(L10n.DeleteQr.buttonTitle), action: {
                    self.viewModel.remove()
                })
            )
        })
    }

    @ViewBuilder
    private var lockView: some View {
        if viewModel.isProActivated {
            EmptyView()
        } else {
            Image(systemName: "lock.fill")
        }
    }

    @ViewBuilder
    private var shareButton: some View {
        viewModel.makeShareView()
    }
}
