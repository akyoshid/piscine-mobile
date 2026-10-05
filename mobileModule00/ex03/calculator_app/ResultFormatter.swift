//
//  ResultFormatter.swift
//  calculator_app
//
//  Created by Akihiro Yoshida on 2026/10/05.
//

import Foundation

enum ResultFormatter {
    static let significantDigits = 15
    // Exponent notation when |value| >= 1e15 or |value| < 1e-6
    static let maxPlainExponent = 14
    static let minPlainExponent = -6

    static func round(_ value: Decimal) -> Decimal {
        if value.isNaN { return value }
        if value.isZero { return 0 }
        var source = value
        var rounded = Decimal()
        let scale = significantDigits - 1 - orderOfMagnitude(value)
        NSDecimalRound(&rounded, &source, scale, .plain)
        return rounded
    }

    // Formats a value already passed through round(_:)
    static func format(_ value: Decimal) -> String {
        if value.isNaN { return CalculationError.invalidExpression.message }
        if value.isZero { return "0" }

        let exponent = orderOfMagnitude(value)
        if minPlainExponent <= exponent && exponent <= maxPlainExponent {
            return trimTrailingZeros(value.description)
        }
        let mantissa = Decimal(
            sign: value.sign,
            exponent: value.exponent - exponent,
            significand: value.significand
        )
        let exponentText = exponent < 0 ? "e-\(-exponent)" : "e+\(exponent)"
        return trimTrailingZeros(mantissa.description) + exponentText
    }

    // floor(log10(|value|)) for a non-zero value
    private static func orderOfMagnitude(_ value: Decimal) -> Int {
        let significandDigits = value.significand.magnitude.description.count
        return significandDigits - 1 + value.exponent
    }

    private static func trimTrailingZeros(_ text: String) -> String {
        guard text.contains(".") else { return text }
        var trimmed = text
        while trimmed.hasSuffix("0") { trimmed.removeLast() }
        if trimmed.hasSuffix(".") { trimmed.removeLast() }
        return trimmed
    }
}
