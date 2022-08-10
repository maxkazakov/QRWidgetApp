//
//  PassAddingViewController.swift
//  QRWidget
//
//  Created by Максим Казаков on 04.07.2021.
//

import UIKit
import SwiftUI
import PassKit

struct PKAddPassesView: UIViewControllerRepresentable {
    typealias Callback = (_ activityType: UIActivity.ActivityType?, _ completed: Bool, _ returnedItems: [Any]?, _ error: Error?) -> Void
    
    let pass: PKPass
    let onFinish: () -> Void
    
    func makeUIViewController(context: Context) -> PKAddPassesViewController {
        let controller = PKAddPassesViewController(pass: pass)!
        controller.delegate = context.coordinator
        return controller
    }
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PKAddPassesViewControllerDelegate {
        let parent: PKAddPassesView

        init(_ parent: PKAddPassesView) {
            self.parent = parent
        }

        func addPassesViewControllerDidFinish(_ controller: PKAddPassesViewController) {
            parent.onFinish()
        }
    }
    
    func updateUIViewController(_ uiViewController: PKAddPassesViewController, context: Context) {
        // nothing to do here
    }
}
