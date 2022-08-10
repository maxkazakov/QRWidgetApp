//
//  CustomTestField.swift
//  QRWidget
//
//  Created by Максим Казаков on 20.10.2021.
//

import UIKit
import SwiftUI

struct CustomTestField: UIViewRepresentable {
    
    let placeholder: String
    @Binding var text: String
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField(frame: .zero)
        
        textField.returnKeyType = UIReturnKeyType.done
        textField.textAlignment = .left
        textField.placeholder = self.placeholder
        textField.autocorrectionType = .no
        textField.clearButtonMode = .always
        textField.delegate = context.coordinator
        textField.clipsToBounds = true
        textField.text = text
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: CustomTestField
        
        init(_ textField: CustomTestField) {
            self.parent = textField
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            let textValue = textField.text ?? ""
            parent.text = textValue
            generalAssembly.appEnvironment.analyticsEnvironment.sendAnalyticsEvent(.qrLabelUpdated, ["value": textValue])
        }
    }
}
