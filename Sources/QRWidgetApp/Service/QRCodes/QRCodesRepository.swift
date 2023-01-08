import UIKit
import QRWidgetCore

class QRCodesRepository {

    init(logMessage: @escaping (String) -> Void = { _ in }) {
        self.logMessage = logMessage
    }

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let logMessage: (String) -> Void

    func loadAllCodes() -> [QRModel] {
        var isDir: ObjCBool = false
        guard FileManager.default.fileExists(atPath: qrCodesDirectory.path, isDirectory: &isDir),
              isDir.boolValue else {
            createQRDirectory()
            return []
        }
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: qrCodesDirectory, includingPropertiesForKeys: nil)
            let jsonFiles = directoryContents.filter { $0.pathExtension == "json" }
            var qrModels: [QRModel] = []

            for jsonFile in jsonFiles {
                if let data = try? Data(contentsOf: jsonFile),
                   let qrModelDto = try? decoder.decode(QRModelDto.self, from: data) {
                    let qrModel = qrModelDto.makeModel()
                    qrModels.append(qrModel)
                }
            }            
            logMessage("QRCodes Repo: Loaded from disc. Count: \(qrModels.count)")
            return qrModels
        } catch {
            logMessage("QRCodes Repo: Failed to load qr codes from directory. Error: \(error)")
            return []
        }
    }

    func addNew(qr: QRModel) {
        saveQRToFile(qr: qr)
    }

    func update(qrModel: QRModel) {
        saveQRToFile(qr: qrModel)
    }

    func remove(id: UUID) {
        removeFile(qrId: id)
    }

    func remove(ids: Set<UUID>) {
        for id in ids {
            removeFile(qrId: id)
        }
    }

    // MARK: - Private

    private func createQRDirectory() {
        do {
            try FileManager.default.createDirectory(
                at: qrCodesDirectory,
                withIntermediateDirectories: false,
                attributes: nil
            )
        } catch {
            logMessage("Failed to create directory: \(qrCodesDirectory)")
        }
    }

    private func saveQRToFile(qr: QRModel) {
        do {
            let dto = QRModelDto(model: qr)
            let data = try encoder.encode(dto)
            let qrFileUrl = fileForQR(qrId: qr.id)
            try data.write(to: qrFileUrl)
        } catch {
            logMessage("failed to save qr: \(qr). error: \(error)")
            preconditionFailure("failed to save qr: \(qr). error: \(error)")
        }
    }

    private func removeFile(qrId: UUID) {
        let qrFileUrl = fileForQR(qrId: qrId)
        try? FileManager.default.removeItem(at: qrFileUrl)
    }

    private func fileForQR(qrId: UUID) -> URL {
        let filename = "\(qrId.uuidString).json"
        return qrCodesDirectory.appendingPathComponent(filename)
    }

    lazy var qrCodesDirectory: URL = {
        let documentsUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)!
        return documentsUrl.appendingPathComponent("QRCodes")
    }()
}
