//
//  EmailSender.swift
//  QRWidget
//
//  Created by Максим Казаков on 17.07.2022.
//

import UIKit
import MessageUI

class EmailSender: NSObject, MFMailComposeViewControllerDelegate {
    var onEmailSentMailComposeViewController: ((Bool) -> Void)?

    func sendEmail(presentingController: UIViewController, completion: @escaping (Bool) -> Void) {
        let recipientEmail = "qrcodes.widget@gmail.com"
        let subject = "Support for QRWidget"
        let body = ""

        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([recipientEmail])
            mail.setSubject(subject)
            self.onEmailSentMailComposeViewController = { [presentingController] isSent in
                Logger.debugLog(message: "Email to developer. Was sent: \(isSent)")
                presentingController.dismiss(animated: true)
                completion(isSent)
                _ = Unmanaged.passUnretained(self).autorelease()
            }
            _ = Unmanaged.passRetained(self)
            presentingController.present(mail, animated: true)
        } else if let emailUrl = createEmailUrl(to: recipientEmail, subject: subject, body: body) {
            UIApplication.shared.open(emailUrl)
        }
    }

    private func createEmailUrl(to: String, subject: String, body: String) -> URL? {
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

        let gmailUrl = URL(string: "googlegmail://co?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let outlookUrl = URL(string: "ms-outlook://compose?to=\(to)&subject=\(subjectEncoded)")
        let yahooMail = URL(string: "ymail://mail/compose?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let sparkUrl = URL(string: "readdle-spark://compose?recipient=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let defaultUrl = URL(string: "mailto:\(to)?subject=\(subjectEncoded)&body=\(bodyEncoded)")

        if let gmailUrl = gmailUrl, UIApplication.shared.canOpenURL(gmailUrl) {
            return gmailUrl
        } else if let outlookUrl = outlookUrl, UIApplication.shared.canOpenURL(outlookUrl) {
            return outlookUrl
        } else if let yahooMail = yahooMail, UIApplication.shared.canOpenURL(yahooMail) {
            return yahooMail
        } else if let sparkUrl = sparkUrl, UIApplication.shared.canOpenURL(sparkUrl) {
            return sparkUrl
        }
        return defaultUrl
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        onEmailSentMailComposeViewController?(result == .sent)
        onEmailSentMailComposeViewController = nil
    }

    deinit {
        print("EmailSender deinit")
    }
}

