//
//  FeatureRowView.swift
//  QRWidget
//
//  Created by Максим Казаков on 08.01.2022.
//

import SwiftUI

struct FeatureView: View {
    let name: String
    var subtitle: String = ""
    var featured = false
    var icon: String?

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(Font.system(.body))
                    .fontWeight(.semibold)
                    .foregroundColor(featured ? Color(UIColor.yellowOnboarding) : .white)

                Text(subtitle)
                    .font(Font.system(.callout))
                    .foregroundColor(featured ? Color(UIColor.yellowOnboarding) : .white)
            }
        } icon: {
            if let iconName = icon {
                Image(systemName: iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.white)
            } else {
                Image(uiImage: UIImage(named: "checkmark")!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
            }
        }
    }
}

struct FeatureView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FeatureView(name: "QR-codes scanner", subtitle: "Use camera or photos to add new QR-code", featured: false)
        }
        .background(Color.black)
    }
}
