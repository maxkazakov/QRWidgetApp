//
//  ScannerView.swift
//  QRWidget
//
//  Created by Максим Казаков on 21.02.2022.
//

import SwiftUI
import UIKit
import AVFoundation
import SimpleToast
//import PurchasesCoreSwift

struct ScannerView: View {

    @StateObject var viewModel: ScannerViewModel
    @Environment(\.sendAnalyticsEvent) var sendAnalyticsEvent

    @State var isGalleryPresented = false
    @State var codeTypes: [AVMetadataObject.ObjectType] = [.qr]
    @State var showToast = false
    @State var isTorchOn = false

    var body: some View {
        ZStack {
            CodeScannerView(
                isScanActive: viewModel.isScanActive,
                codeTypes: codeTypes,
                scanMode: .continuous,
                showViewfinder: true,
                shouldVibrateOnSuccess: viewModel.shouldVibrateOnSuccess,
                isTorchOn: isTorchOn,
                isGalleryPresented: $isGalleryPresented) { response in
                    switch response {
                    case .success(let result):
                        viewModel.qrCodeFound(data: result.string, source: result.source)

                    case .failure(let error):
                        self.viewModel.failedToRecognize()
                        self.showToast = true
                        Logger.debugLog(message: "Scan error: \(error.localizedDescription)")
                    }
                }
                .ignoresSafeArea(.container, edges: .top)

            VStack {
                HStack {
                    Spacer()
                    torchButton
                }
                Spacer()
            }
            .padding(20)

            let transition = AnyTransition.move(edge: .bottom).combined(with: .opacity)
            ZStack {
                VStack {
                    Spacer()
                    if viewModel.batchModeOn {
                        stopBatchScanButton
                            .transition(transition)
                    } else {
                        HStack {
                            batchScanButton
                            Spacer()
                            galleryButton
                        }
                        .transition(transition)
                    }
                }
                .padding(20)
                .animation(.spring(response: 0.35, dampingFraction: 0.45, blendDuration: 0).speed(1), value: viewModel.batchModeOn)
            }
        }
        .alert(isPresented: $viewModel.showBatchScanHint, content: {
            Alert(
                title: Text(L10n.Scanner.About.title),
                message: Text(L10n.Scanner.About.subtitle),
                primaryButton: .default(Text(L10n.Scanner.startButton), action: { viewModel.startBatchScan() }),
                secondaryButton: .cancel()
            )
        })
        .fullScreenCover(isPresented: $viewModel.showPaywall) {
            generalAssembly.makePaywallView(sourceScreen: .batchScan)
        }
        .simpleToast(isPresented: $showToast, options: SimpleToastOptions(alignment: .top, hideAfter: 1.5, backdrop: nil, animation: nil, modifierType: .slide)) {
            toastView
        }
        .onChange(of: isGalleryPresented, perform: {
            viewModel.isScanActive = !$0
        })
    }

    @ViewBuilder
    var torchButton: some View {
        Button(action: {
            self.isTorchOn.toggle()
            sendAnalyticsEvent(.tapTorchIcon, ["isOn": self.isTorchOn])
        }, label: {
            ZStack {
                Circle()
                    .foregroundColor(Color(UIColor.black.withAlphaComponent(0.5)))

                Group {
                    if isTorchOn {
                        Image(uiImage: Asset.flashOn.image)
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                    } else {
                        Image(uiImage: Asset.flashOff.image)
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                    }
                }
            }
            .frame(width: 50, height: 50)
        })
    }

    @ViewBuilder
    var galleryButton: some View {
        Button(action: {
            sendAnalyticsEvent(.tapGalleryIcon, nil)
            self.isGalleryPresented = true
        }, label: {
            ZStack {
                Circle()
                    .foregroundColor(Color(UIColor.black.withAlphaComponent(0.5)))
                Image(uiImage: Asset.gallery.image)
                    .resizable()
                    .frame(width: 44, height: 44)
            }
            .frame(width: 50, height: 50)
        })
    }

    @ViewBuilder
    var batchScanButton: some View {
        Button(action: {
            viewModel.startBatchScan()
        }, label: {
            ZStack {
                Text(L10n.Scanner.scanButton)
                    .fontWeight(.medium)
                    .padding()
                    .foregroundColor(Color.white)
                    .background(Capsule()
                        .foregroundColor(Color(UIColor.black.withAlphaComponent(0.5))))
            }
        })
    }

    @ViewBuilder
    var stopBatchScanButton: some View {
        Button(action: {
            viewModel.finishBatchScan()
        }, label: {
            VStack {
                Text(L10n.Scanner.stopButton)
                    .fontWeight(.medium)

                Text(L10n.Scanner.scannedCount(viewModel.batchScanResult?.codes.count ?? 0))
                    .font(.caption)

            }
            .padding()
            .foregroundColor(Color.white)
            .background(Capsule()
                .foregroundColor(Color(UIColor.black.withAlphaComponent(0.5))))
        })
    }

    @ViewBuilder
    var toastView: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle")
            Text(L10n.Scanner.qrNotFound)
        }
        .padding()
        .background(Capsule()
            .foregroundColor(Color(UIColor.black.withAlphaComponent(0.5))))
        .foregroundColor(Color.white)
        .cornerRadius(10)
    }
}
