//
//  QRTypes.swift
//  QRWidget
//
//  Created by Максим Казаков on 23.02.2022.
//

import UIKit
import Contacts

public enum QRCodeDataType {
    case rawText(String)
    case url(URL)

    public static func make(from string: String) -> QRCodeDataType {
        if let url = URL(string: string), string.hasPrefix("http") || string.hasPrefix("www") {
            return .url(url)
        }

        return .rawText(string)
    }
}

