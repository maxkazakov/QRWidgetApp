//
//  File.swift
//  
//
//  Created by Максим Казаков on 03.08.2022.
//

import Foundation

class Logger {
    static func debugLog(message: String) {
        generalAssembly.appEnvironment.debugLog(message)
    }
}
