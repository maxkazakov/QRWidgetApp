
import SwiftUI
import Combine

struct AvailableProductsView: View {

    @ObservedObject var viewModel: PaywallViewModel

    var body: some View {
        if viewModel.products.isEmpty {
            HStack(spacing: 16) {
                let mocks: [QRProduct] = [.mock(id: "1"), .mock(id: "2")]
                ForEach(mocks, id: \.id) { product in
                    ProductView(
                        title: product.title,
                        subtitle: product.subtitle,
                        isSelected: product.id == "1",
                        safePercent: product.safePercent
                    )
                    .redacted(reason: .placeholder)
                }
            }
        } else {
            VStack(spacing: 16) {
                ForEach(viewModel.products, id: \.id) { product in
                    ProductView(
                        title: product.title,
                        subtitle: product.subtitle,
                        isSelected: product == viewModel.selectedProduct,
                        safePercent: product.safePercent
                    )
                    .onTapGesture(perform: {
                        viewModel.select(product)
                    })
                }
            }
        }
    }
}

struct ProductInfoFullWidthView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(UIColor.purple)
            AvailableProductsView(viewModel: PaywallViewModel.makeSuccessStub())
                .padding(.horizontal)
        }
            .previewLayout(.fixed(width: 300, height: 400))
    }
}
