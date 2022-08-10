//
//  FormatHelpers.swift
//  QRWidget
//
//  Created by Максим Казаков on 16.04.2022.
//

import Foundation

class FormatsHelper {

    static func formatRelative(_ date: Date) -> String {
        if date.timeIntervalSinceNow > -5 {
            return "just now"
        } else if date.timeIntervalSinceNow > -60 {
            return "a few seconds ago"
        } else if date.timeIntervalSinceNow < -60 * 60 * 24 * 31 {
            // more than month past
            return formatter.string(from: date)
        }

        return relativeDateFormatter.localizedString(for: date, relativeTo: Date())
    }

    static func formatDay(_ date: Date) -> String {
        return dayFormatter.string(from: date)
    }

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.doesRelativeDateFormatting = true
        formatter.timeStyle = .none
        return formatter
    }()

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    private static let relativeDateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short        
        return formatter
    }()
}
