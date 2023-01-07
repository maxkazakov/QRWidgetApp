import Foundation

class Logger {
    static func debugLog(message: String) {
        generalAssembly.appEnvironment.debugLog(message)
    }
}
