
import Foundation
import QRWidgetCore

// Loading QRs from state for showing on widget
public func loadQRModels() -> [QRModel] {
    QRCodesRepository().loadAllCodes()
}
