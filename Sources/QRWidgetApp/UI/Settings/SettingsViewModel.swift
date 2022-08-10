//
//  SettingsViewModel.swift
//  QRWidget
//
//  Created by Максим Казаков on 05.02.2022.
//

import SwiftUI

class SettingsViewModel: ViewModel {

    let settingsService: SettingsService

    @Published var showSubscriptionOffer = false
    @Published var vibrateOnCodeRecognized = true

    init(settingsService: SettingsService) {
        self.settingsService = settingsService
        super.init()

        self.vibrateOnCodeRecognized = settingsService.vibrateOnCodeRecognized
        $isProActivated
            .removeDuplicates()
            .sink(receiveValue: { [weak self] isActivated in
                self?.showSubscriptionOffer = !isActivated
            })
            .store(in: &cancellableSet)

        $vibrateOnCodeRecognized
            .sink(receiveValue: { [weak self] in
                self?.settingsService.vibrateOnCodeRecognized = $0
            })
            .store(in: &cancellableSet)
    }

    func sendEmailToDeveloper() {
        route(.mailToDeveloper(onComplete: { isSent in
            // Say thanks to user for email
        }))
    }

    func writeReview() {
        guard let writeReviewURL = URL(string: "https://apps.apple.com/app/id1574087047?action=write-review") else {
            Logger.debugLog(message: "requestReviewManually. Expected a valid URL")
            return
        }
        UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
    }
}
