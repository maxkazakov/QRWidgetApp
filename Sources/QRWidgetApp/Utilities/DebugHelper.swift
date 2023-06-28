
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
            label: "Movie ticket",
            backgroundColor: UIColor.white,
            foregroundColor: UIColor(hexString: "01098C")
        )
        let qrCode_2 = CodeModel(dateCreated: todayDate.addingTimeInterval(-2), data: .string(appstore), type: .qr, label: "QR codes app",
                               backgroundColor: UIColor(hexString: "012F7B"),
                               foregroundColor: UIColor(hexString: "FEC700"))
        let qrCode_3 = CodeModel(dateCreated: yesterdayDate.addingTimeInterval(-1), data: .string(flight), type: .qr, label: "Flight to London",
                               backgroundColor: UIColor.black,
                               foregroundColor: UIColor(hexString: "FFA7C8"))
        let qrCode_4 = CodeModel(dateCreated: yesterdayDate.addingTimeInterval(-2), data: .string(appstore), type: .qr, label: "Link to the app")

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
