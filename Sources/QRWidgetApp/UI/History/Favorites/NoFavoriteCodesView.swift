
import SwiftUI

struct NoFavoriteCodesView: View {
    var body: some View {
        VStack(spacing: 12) {
            Spacer()
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
            Spacer()
        }
        .padding(20)
    }
}

