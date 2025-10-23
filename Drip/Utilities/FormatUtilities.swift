//
//  FormatUtilities.swift
//  Drip
//
//  Currency and date formatting utilities
//

import Foundation

extension Decimal {
    func formatted(style: NumberFormatter.Style = .decimal, minimumFractionDigits: Int = 2, maximumFractionDigits: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = style
        formatter.minimumFractionDigits = minimumFractionDigits
        formatter.maximumFractionDigits = maximumFractionDigits
        return formatter.string(from: self as NSDecimalNumber) ?? "0.00"
    }

    func formattedCurrency(currencySymbol: String = "$") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        let formatted = formatter.string(from: self as NSDecimalNumber) ?? "0.00"
        return "\(currencySymbol)\(formatted)"
    }
}

extension Date {
    func formattedShort() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }

    func formattedMedium() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
}
