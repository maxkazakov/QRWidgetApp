//
//  WalletPassEnvironment.swift
//  
//
//  Created by Максим Казаков on 09.08.2022.
//

import Foundation
import PassKit
import Combine

public struct WalletPassInputParams {
    public init(serialNumber: String, data: String, label: String) {
        self.serialNumber = serialNumber
        self.data = data
        self.label = label
    }

    public let serialNumber: String
    public let data: String
    public let label: String
}

public struct WalletPassEnvironment {

    public init(passIdentifier: @escaping () -> String,
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
