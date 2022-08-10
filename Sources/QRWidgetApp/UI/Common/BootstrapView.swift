//
//  BootstrapView.swift
//  QRWidget
//
//  Created by Максим Казаков on 17.10.2021.
//

import SwiftUI

struct BootstrapView: View {
    var body: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
            .scaleEffect(2.0)
    }
}


struct BootstrapView_Previews: PreviewProvider {
    static var previews: some View {
        BootstrapView()
    }
}
