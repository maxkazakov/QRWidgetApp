//
//  QRCodesRepository.swift
//  QRWidget
//
//  Created by Максим Казаков on 13.02.2022.
//

import Combine
import UIKit
import QRWidgetCore

class QRCodesRepository {

    init(logMessage: @escaping (String) -> Void) {
        self.logMessage = logMessage
    }

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let logMessage: (String) -> Void

    let qrCodesPublisher = CurrentValueSubject<[QRModel], Never>([])
    private let queue = DispatchQueue(label: "QRCodesRepository")
    var qrCodes: [QRModel] {
        qrCodesPublisher.value
    }

    func loadAllQrFromStoragePublisher() -> AnyPublisher<Void, Never> {
        Deferred {
            Future<Void, Never> { promise in
                self.loadAllQrFromStorage()
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }

    func loadAllQrFromStorage() {
        var isDir: ObjCBool = false
        guard FileManager.default.fileExists(atPath: qrCodesDirectory.path, isDirectory: &isDir),
              isDir.boolValue else {
            createQRDirectory()
            return
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
            qrModels.sort(by: { $0.dateCreated > $1.dateCreated })
            self.qrCodesPublisher.send(qrModels)

            logMessage("QRCodes Repo: Loaded from disc. Count: \(qrCodesPublisher.value.count)")
        } catch {
            logMessage("QRCodes Repo: Failed to load qr codes from directory. Error: \(error)")
        }
    }

    func addNew(qr: QRModel) {
        var newCodes = qrCodesPublisher.value
        newCodes.append(qr)
        qrCodesPublisher.send(newCodes)

        saveQRToFile(qr: qr)
    }

    func get(id: UUID) -> QRModel? {
        return qrCodesPublisher.value.first(where: { $0.id == id })
    }

    func update(qrModel: QRModel) {
        var newCodes = qrCodesPublisher.value
        guard let idx = newCodes.firstIndex(where: { $0.id == qrModel.id }) else {
            return
        }
        newCodes[idx] = qrModel
        qrCodesPublisher.send(newCodes)

        saveQRToFile(qr: qrModel)
    }

    func remove(id: UUID) {
        var newCodes = qrCodesPublisher.value
        guard let idx = newCodes.firstIndex(where: { $0.id == id }) else {
            return
        }
        newCodes.remove(at: idx)
        qrCodesPublisher.send(newCodes)

        removeFile(qrId: id)
    }

    func remove(ids: Set<UUID>) {
        var newCodes = qrCodesPublisher.value
        newCodes.removeAll { code in
            ids.contains(code.id)
        }
        qrCodesPublisher.send(newCodes)
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
