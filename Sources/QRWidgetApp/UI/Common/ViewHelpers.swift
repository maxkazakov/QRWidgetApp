//
//  ViewHelpers.swift
//  QRWidget
//
//  Created by Максим Казаков on 04.07.2021.
//

import SwiftUI

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ conditional: Bool, content: (Self) -> Content) -> some View {
         if conditional {
             content(self)
         } else {
             self
         }
     }
}
