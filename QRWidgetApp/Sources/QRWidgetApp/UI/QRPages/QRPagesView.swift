//
//  QRPagesView.swift
//  QRWidget
//
//  Created by Максим Казаков on 28.10.2021.
//

import SwiftUI
import SimpleToast

struct QRPagesView: View {

    @StateObject var viewModel: QRPagesViewModel
    
    var body: some View {
        ZStack {
            if viewModel.qrCodesList.count > 0 {
                VStack {
                    Spacer()
                    TabView(selection: $viewModel.selectedQr) {
                        ForEach(viewModel.qrCodesList, id: \.id) { qrModel in
                            QRPageItemView(model: qrModel, proVersionActivated: viewModel.isProActivated)
                                .id(qrModel.id)
                                .tag(qrModel.id)
                        }
                        .padding(20)
                    }
                    .frame(height: 420)
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationViewStyle(.stack)

                    Spacer()
                    Spacer()
                }
            }
            else {
                NoQRView()
                    .padding(.bottom, 20)
            }

            if viewModel.showNeedToPaySubscription {
                VStack {
                    NeedToBuyView()
                    Spacer()
                }
                .padding(.horizontal, 16)
            }
        }
        .simpleToast(isPresented: $viewModel.showFlipTip, options: SimpleToastOptions(alignment: .top, hideAfter: 10, modifierType: .slide)) {
            HStack {
                Image(systemName: "info.circle")
                Text(L10n.FlipperQr.Info.text)
            }
            .padding()
            .background(
                Capsule()
                    .foregroundColor(Color(UIColor.primaryColor))
            )
            .foregroundColor(Color.white)
        }
        .onAppear(perform: {
            viewModel.onAppear()
            UIPageControl.appearance().currentPageIndicatorTintColor = .primaryColor
            UIPageControl.appearance().pageIndicatorTintColor = UIColor.gray
        })
    }
}

struct NavBarIcon: View {
    let sfSymbol: String
    
    var body: some View {
        Image(systemName: sfSymbol)
            .font(.system(size: 20))
    }
}
