//
//  SubscriptionInfoView.swift
//  QRWidget
//
//  Created by Максим Казаков on 05.02.2022.
//

import SwiftUI

struct SettingActivateView: View {    

    var body: some View {
        ZStack(alignment: .leading) {
            LinearGradient.horizontal

            VStack(alignment: .leading, spacing: 4) {
                Text(L10n.Settings.Pro.title)
                    .font(.title)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                Text(L10n.Settings.Pro.describtion)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
            }
            .padding(16)
        }

        .cornerRadius(12)
        .shadow(radius: 3)
    }
}

struct SettingActivateView_Previews: PreviewProvider {
    static var previews: some View {
        SettingActivateView()
            .previewLayout(.fixed(width: 500, height: 100))
    }
}


