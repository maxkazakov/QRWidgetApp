
import Foundation
import QRWidgetCore
import UIKit

class DebugHelper {
    private let qrService: QRCodesService
    private let favoritesService: FavoritesService    

    init(qrService: QRCodesService, favoritesService: FavoritesService) {
        self.qrService = qrService
        self.favoritesService = favoritesService
    }

    func removeAllQRs() {
        qrService.qrCodesPublisher.value.forEach { code in
            qrService.removeQR(id: code.id)
        }
    }

    func makeMockQRCodes() {
        let todayDate = Date()
        let yesterdayDate = Date().addingTimeInterval(-24 * 60 * 60)

        let ticket = "https://www.ticket.com/f6e9872"
        let flight = "https://flightticket.com/k8g5b4v"
        let appstore = "https://apps.apple.com/us/app/qr-code-widget-scanner-reader/id1574087047"
        let qrCode_1 = CodeModel(
            dateCreated: todayDate.addingTimeInterval(-1),
            data: .string(ticket),
            type: .qr,
            label: L10n.Debug.Qr.moveTicket,
            errorCorrectionLevel: .H,
            backgroundColor: UIColor(hexString: "D6E1FC"),
            foregroundColor: UIColor(hexString: "2253CA"),
            qrStyle: QRStyle(eye: .squircle, onPixels: .circle)
        )
        let qrCode_2 = CodeModel(
            dateCreated: todayDate.addingTimeInterval(-2),
            data: .string(appstore),
            type: .qr,
            label: L10n.Debug.Qr.flight,
            errorCorrectionLevel: .L,
            backgroundColor: UIColor(hexString: "3E1156"),
            foregroundColor: UIColor(hexString: "DE789D"),
            qrStyle: QRStyle(eye: .circle, onPixels: .pointy)
        )
        let qrCode_3 = CodeModel(
            dateCreated: yesterdayDate.addingTimeInterval(-1),
            data: .string(flight),
            type: .qr,
            label: L10n.Debug.Qr.twitter,
            errorCorrectionLevel: .L,
            backgroundColor: UIColor(hexString: "102F77"),
            foregroundColor: UIColor(hexString: "F6CA44"),
            qrStyle: QRStyle(eye: .roundedRect, onPixels: .curvePixel)
        )
        let qrCode_4 = CodeModel(
            dateCreated: yesterdayDate.addingTimeInterval(-2),
            data: .string(appstore),
            type: .qr,
            label: L10n.Debug.Qr.linkToApp
        )

        [qrCode_1, qrCode_2, qrCode_3].forEach { favoritesService.addSavorite(id: $0.id) }
        qrService.addNewQrCodes(qrModels: [qrCode_1, qrCode_2, qrCode_3, qrCode_4])

        let batchId = UUID()
        let batchDate = todayDate
        var batchList = [qrCode_1, qrCode_2, qrCode_3, qrCode_4]
        for i in 0..<batchList.count {
            batchList[i].id = UUID()
            batchList[i].dateCreated = batchDate
            batchList[i].batchId = batchId
        }
        qrService.addNewQrCodes(qrModels: batchList)
    }
}
