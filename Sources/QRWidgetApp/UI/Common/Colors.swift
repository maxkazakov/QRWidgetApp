//
//  Colors.swift
//  QRWidget
//
//  Created by Максим Казаков on 08.01.2022.
//

import UIKit
import SwiftUI

extension UIColor {
    static let primaryColor = UIColor(named: "OnboardingColor")!
    static let yellowOnboarding = UIColor(named: "yellowOnboarding")!
}

extension Color {
    static let primaryColor = Color(UIColor.primaryColor)
    static let yellowOnboarding = Color(UIColor.yellowOnboarding)
}

extension LinearGradient {
    static let vertical = LinearGradient(gradient: Gradient(colors: [Color.purple, Color.primaryColor]), startPoint: .top, endPoint: .bottom)
    static let horizontal = LinearGradient(gradient: Gradient(colors: [Color.primaryColor, Color.purple]), startPoint: .leading, endPoint: .trailing)
}
