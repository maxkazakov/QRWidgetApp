//
//  MainButton.swift
//  QRWidget
//
//  Created by Максим Казаков on 27.06.2021.
//

import SwiftUI

struct MainButtonStyle: ButtonStyle {
    
    init(titleColor: UIColor = .white, backgroundColor: UIColor = .primaryColor) {
        self.titleColor = titleColor
        self.backgroundColor = backgroundColor
    }
    
    let titleColor: UIColor
    let backgroundColor: UIColor
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 18, weight: .semibold, design: .default))
            .foregroundColor(configuration.isPressed ? Color(titleColor.withAlphaComponent(0.6)) : Color(titleColor))
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(configuration.isPressed ? Color(backgroundColor.withAlphaComponent(0.6)) : Color(backgroundColor))
            .clipShape(Capsule())
            
    }
}

struct BorderButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 18, weight: .semibold, design: .default))
            .foregroundColor(configuration.isPressed ? Color(UIColor.primaryColor.withAlphaComponent(0.6)) : Color.primaryColor)
            .frame(minHeight: 50)
            .padding(.horizontal, 16)
            .overlay(Capsule().stroke(lineWidth: 3).foregroundColor(Color.primaryColor))
            .clipShape(Capsule())
    }
}
