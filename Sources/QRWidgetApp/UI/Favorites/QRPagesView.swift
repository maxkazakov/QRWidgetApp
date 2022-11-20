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
    @Environment(\.sendAnalyticsEvent) var sendAnalyticsEvent

    var body: some View {
        ZStack {
            if viewModel.qrCodesList.count > 0 {
                ZStack {
                    GeometryReader { proxy in
                        Image(uiImage: Asset.Backgrounds.xmaxBranches.image)
                            .resizable()
                            .scaledToFill()
                            .ignoresSafeArea()
                            .frame(width: proxy.size.width)
                    }

                    VStack {
                        Spacer()
                        TabView(selection: $viewModel.selectedQr) {
                            ForEach(viewModel.qrCodesList, id: \.id) { qrModel in
                                QRPageItemView(
                                    model: qrModel,
                                    proVersionActivated: viewModel.isProActivated,
                                    // This is test for screen with x-mas tree
                                    forcedForegroundColor: Asset.QRColor.xmasBranches.color,
                                    forcedBackgroundColor: UIColor.white
                                )
                                .tag(qrModel.id)
                                .id(qrModel.id)
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

                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            detailsButton
                        }
                        .padding(20)
                    }
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
                    .foregroundColor(Color.primaryColor)
            )
            .foregroundColor(Color.white)
        }
        .onAppear(perform: {
            viewModel.onAppear()
            UIPageControl.appearance().currentPageIndicatorTintColor = Asset.primaryColor.color
            UIPageControl.appearance().pageIndicatorTintColor = UIColor.gray
        })
    }

    @ViewBuilder
    var detailsButton: some View {
        Button(action: {
            sendAnalyticsEvent(.openDetails, ["source": AnalyticsSource.OpenDetails.favorites.rawValue])
            viewModel.showDetails()
        }, label: {
            ZStack {
                Circle()
                    .foregroundColor(Color(UIColor.white))
                Image(systemName: "ellipsis")
                    .imageScale(.large)
                    .foregroundColor(Color.black)
            }
            .frame(width: 50, height: 50)
        })
    }

    @ViewBuilder
    var shareButton: some View {
        Button(action: {

        }, label: {
            ZStack {
                Circle()
                    .foregroundColor(Color.white)
                Image(systemName: "square.and.arrow.up")
                    .imageScale(.large)
                    .foregroundColor(Color.black)
            }
            .frame(width: 50, height: 50)
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
