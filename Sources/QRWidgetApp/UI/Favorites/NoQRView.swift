//
//  RootView.swift
//  QRWidget
//
//  Created by Максим Казаков on 27.06.2021.
//

import SwiftUI

struct NoQRView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(uiImage: Asset.emptyFav.image)
            VStack(spacing: 8) {
                Text(L10n.Favorites.Empty.title)
                    .font(.title3)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)

                Text(L10n.Favorites.Empty.subtitle)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(20)
    }
}

struct NoHistoryView: View {
    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(uiImage: Asset.emptyHistory.image)
            VStack(spacing: 8) {
                Text(L10n.History.Empty.title)
                    .font(.title3)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)

                Text(L10n.History.Empty.subtitle)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            Spacer()
        }
        .padding(20)
    }
}


struct NoQRView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NoQRView()
            NoHistoryView()
        }
    }
}
