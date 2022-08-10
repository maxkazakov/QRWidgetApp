//
//  PassButton.swift
//  QRWidget
//
//  Created by Максим Казаков on 04.07.2021.
//

import UIKit
import SwiftUI
import PassKit

struct PassButton: UIViewRepresentable {

    let onClick: () -> Void
    let actionId = UIAction.Identifier("tap_action_id")

    func makeUIView(context: Context) -> PKAddPassButton {
        let passButton = PKAddPassButton(addPassButtonStyle: PKAddPassButtonStyle.black)
        addAction(button: passButton)
        return passButton
    }

    func updateUIView(_ uiView: PKAddPassButton, context: Context) {
        uiView.removeAction(identifiedBy: actionId, for: .touchUpInside)
        addAction(button: uiView)
    }
    
    private func addAction(button: PKAddPassButton) {
        let action = UIAction(identifier: actionId, handler: { _ in
            onClick()
        })
        button.addAction(action, for: .touchUpInside)
    }
}

struct PassButton_Previews: PreviewProvider {
    static var previews: some View {
        PassButton(onClick: {})
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 44)
            .padding(40)
    }
}
