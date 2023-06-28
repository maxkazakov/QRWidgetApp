//
//  WalletPassEnvironment.swift
//  
//
//  Created by Максим Казаков on 09.08.2022.
//

import Foundation
import PassKit
import Combine
import QRWidgetCore

public struct WalletPassInputParams {

    public enum DataType {
        case string(String)
    }

    public init(serialNumber: String, data: DataType, label: String, codeType: CodeType) {
        self.serialNumber = serialNumber
        self.data = data
        self.label = label
        self.codeType = codeType
    }

    public let serialNumber: String
    public let data: DataType
    public let label: String
    public let codeType: CodeType
}

public struct WalletPassEnvironment {
    public init(
        passIdentifier: @escaping () -> String,
        createPass: @escaping (WalletPassInputParams) -> AnyPublisher<PKPass, Error>
    ) {
        self.createPass = createPass
        self.passIdentifier = passIdentifier
    }

    var createPass: (WalletPassInputParams) -> AnyPublisher<PKPass, Error>
    var passIdentifier: () -> String
}

public extension WalletPassEnvironment {
    static let unimplemented = WalletPassEnvironment(
        passIdentifier: { "fakepass.com" },
        createPass: { _ in
            Fail(error: NSError(domain: "WalletPass", code: 1, userInfo: [NSLocalizedDescriptionKey: "Pass creation is not implemented"])).eraseToAnyPublisher()
        }
    )
}
