//
//  ProductsInfoView.swift
//  QRWidget
//
//  Created by Максим Казаков on 15.01.2022.
//

import SwiftUI

struct ProductsInfoView: View {

    @ObservedObject var viewModel: PaywallViewModel

    @State var titleHeight = CGFloat.zero
    @State var subtitleHeight = CGFloat.zero

    var body: some View {
        if viewModel.products.isEmpty {
            HStack(spacing: 16) {
                let mocks = [QRProduct.mock(id: "1"),
                             QRProduct.mock(id: "2")]
                ForEach(mocks, id: \.id) { product in
                    SubscriptionInfoView(
                        trialText: product.title,
                        priceText: product.priceInfo,
                        isSelected: product.id == "1",
                        isPopular: product.id == "1",
                        titleHeight: $titleHeight,
                        subtitleHeight: $subtitleHeight
                    )
                    .redacted(reason: .placeholder)
                }
            }
            .onPreferenceChange(TitleHeightKey.self) {
                self.titleHeight = $0
            }
            .onPreferenceChange(SubtitleHeightKey.self) {
                self.subtitleHeight = $0
            }
        } else {
            HStack(spacing: 16) {
                ForEach(viewModel.products, id: \.id) { product in
                    SubscriptionInfoView(
                        trialText: product.title,
                        priceText: product.priceInfo,
                        isSelected: product == viewModel.selectedProduct,
                        isPopular: product.isPopular,
                        titleHeight: $titleHeight,
                        subtitleHeight: $subtitleHeight
                    )
                    .onTapGesture(perform: {
                        viewModel.select(product)
                    })
                }
            }
            .onPreferenceChange(TitleHeightKey.self) {
                self.titleHeight = $0
            }
            .onPreferenceChange(SubtitleHeightKey.self) {
                self.subtitleHeight = $0
            }
        }
    }
}

struct TitleHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct SubtitleHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}


struct ProductsInfoView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            GeometryReader { _ in
                ProductsInfoView(viewModel: PaywallViewModel.makeSuccessStub())
                    .padding(30)
            }
            .background(Color.red.ignoresSafeArea())

            GeometryReader { _ in
                ProductsInfoView(viewModel: PaywallViewModel.makeLoadingStub())
                    .padding(30)
            }
            .background(Color.red.ignoresSafeArea())

        }
    }
}
