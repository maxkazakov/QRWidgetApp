//
//  Colors.swift
//  QRWidget
//
//  Created by Максим Казаков on 08.01.2022.
//

import UIKit
import SwiftUI

extension Color {
    static let primaryColor = Color(Asset.primaryColor.color)
    static let yellowOnboarding = Color(Asset.yellowOnboarding.color)
}

extension LinearGradient {
    static let vertical = LinearGradient(gradient: Gradient(colors: [Color.purple, Color.primaryColor]), startPoint: .top, endPoint: .bottom)
    static let horizontal = LinearGradient(gradient: Gradient(colors: [Color.primaryColor, Color.purple]), startPoint: .leading, endPoint: .trailing)
}
