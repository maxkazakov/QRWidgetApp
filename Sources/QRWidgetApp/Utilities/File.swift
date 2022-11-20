//
//  File.swift
//  
//
//  Created by Максим Казаков on 14.11.2022.
//

import Foundation
import QRWidgetCore
import UIKit

class DebugHelper {
    private let qrService: QRCodesService
    private let favoritesService: FavoritesService
    private let repository: QRCodesRepository

    init(qrService: QRCodesService, favoritesService: FavoritesService, repository: QRCodesRepository) {
        self.qrService = qrService
        self.favoritesService = favoritesService
        self.repository = repository
    }

    func removeAllQRs() {
        repository.qrCodes.forEach { code in
            qrService.removeQR(id: code.id)
        }
    }

    func makeMockQRCodes() {
        let todayDate = Date()
        let yesterdayDate = Date().addingTimeInterval(-24 * 60 * 60)

        let ticket = "https://www.ticket.com/f6e9872"
        let flight = "https://flightticket.com/k8g5b4v"
        let appstore = "https://apps.apple.com/us/app/qr-code-widget-scanner-reader/id1574087047"
        let qrCode_1 = QRModel(
            dateCreated: todayDate.addingTimeInterval(-1),
            qrData: ticket,
            label: "Movie ticket",
            backgroundColor: UIColor.white,
            foregroundColor: UIColor(hexString: "01098C")
        )
        let qrCode_2 = QRModel(dateCreated: todayDate.addingTimeInterval(-2), qrData: appstore, label: "QR codes app",
                               backgroundColor: UIColor(hexString: "012F7B"),
                               foregroundColor: UIColor(hexString: "FEC700"))
        let qrCode_3 = QRModel(dateCreated: yesterdayDate.addingTimeInterval(-1), qrData: flight, label: "Flight to London",
                               backgroundColor: UIColor.black,
                               foregroundColor: UIColor(hexString: "FFA7C8"))
        let qrCode_4 = QRModel(dateCreated: yesterdayDate.addingTimeInterval(-2), qrData: appstore, label: "Link to the app")

        qrService.createManyQrCodes(qrModels: [qrCode_1, qrCode_2, qrCode_3, qrCode_4])

        let batchId = UUID()
        let batchDate = todayDate
        var batchList = [qrCode_1, qrCode_2, qrCode_3, qrCode_4]
        for i in 0..<batchList.count - 1 {
            batchList[i].id = UUID()
            batchList[i].batchId = batchId
            batchList[i].dateCreated = batchDate
            batchList[i].batchId = batchId
        }
        qrService.createManyQrCodes(qrModels: batchList)
    }
}

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
}
