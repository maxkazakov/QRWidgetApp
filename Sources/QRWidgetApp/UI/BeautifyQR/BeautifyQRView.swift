
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
        ZStack {
            Form {
                Section {
                    VStack(spacing: 4) {
                        HStack {
                            Spacer()
                            QRCodeTileView(
                                data: viewModel.qrModel.data,
                                codeType: viewModel.qrModel.type,
                                foreground: viewModel.foregroundColor,
                                background: viewModel.backgroundColor,
                                errorCorrectionLevel: viewModel.errorCorrectionLevel,
                                qrStyle: viewModel.qrStyle
                            )
                            Spacer()
                        }
                        if viewModel.checkIfProFeaturesChanged() {
                            HStack(alignment: .top) {
                                Image(systemName: "info.circle")
                                    .imageScale(.small)
                                Text(L10n.ChangeAppearance.fliptip)
                                    .multilineTextAlignment(.center)
                                    .font(.caption)
                            }
                            .foregroundColor(.gray).offset(x: 0, y: 12)
                        }
                    }
                    .padding(.vertical, 16)
                }

                if viewModel.showQRSpecificSettings {
                    Section(
                        content: {
                            Picker(L10n.QrStyle.eye, selection: $viewModel.qrStyle.eye) {
                                ForEach(QRStyle.Eye.allCases) { eye in
                                    Text(eye.description).tag(eye)
                                }
                            }

                            Picker(L10n.QrStyle.pixels, selection: $viewModel.qrStyle.onPixels) {
                                ForEach(QRStyle.OnPixels.allCases) { onPixels in
                                    Text(onPixels.description).tag(onPixels)
                                }
                            }
                        },
                        header: {
                            Label(
                                title: { Text("Shapes") },
                                icon: { lockView }
                            )
                        }
                    )
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

                if viewModel.showQRSpecificSettings {
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
            }
            .listStyle(.insetGrouped)

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
                .buttonStyle(MainButtonStyle(backgroundColor: .tintColor))
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $viewModel.showPaywall) {
            generalAssembly.makePaywallView(sourceScreen: .changeAppearance)
        }
        .navigationTitle(L10n.ChangeAppearance.title)
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

import QRWidgetCore

struct BeautifyQRView_Previews: PreviewProvider {
    static var previews: some View {
        BeautifyQRView(
            viewModel: BeautifyQRViewModel(
                qrModel: CodeModel(data: .string("something"), type: .qr, foregroundColor: .red)                
            )
        )
    }
}
