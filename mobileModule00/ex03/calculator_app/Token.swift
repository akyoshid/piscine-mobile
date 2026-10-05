//
//  Token.swift
//  calculator_app
//
//  Created by Akihiro Yoshida on 2026/10/05.
//

import Foundation

enum Operator: Equatable {
    case add, subtract, multiply, divide

    var symbol: String {
        switch self {
        case .add: return "+"
        case .subtract: return "−"
        case .multiply: return "×"
        case .divide: return "÷"
        }
    }

    var hasHighPrecedence: Bool {
        self == .multiply || self == .divide
    }
}

struct NumberToken: Equatable {
    static let maxDigits = 15

    // Sign is stored as an ASCII "-" (e.g. "-", "-0.", "12.5")
    private(set) var text: String
    // Non-nil only for an atomic token carried over from a result in exponent notation
    private(set) var atomicValue: Decimal?

    init(_ text: String) {
        self.text = text
        self.atomicValue = nil
    }

    init(carrying value: Decimal, formatted: String) {
        self.text = formatted
        self.atomicValue = formatted.contains("e") ? value : nil
    }

    var isAtomic: Bool { atomicValue != nil }

    var isNegative: Bool { text.hasPrefix("-") }

    var body: String { isNegative ? String(text.dropFirst()) : text }

    var isIncomplete: Bool { body.isEmpty || body.hasSuffix(".") }

    var hasDot: Bool { body.contains(".") }

    // Digits counted against maxDigits: the leading "0" of "0" or "0.xx" is not counted
    var digitCount: Int {
        let digits = body.filter(\.isNumber).count
        return body.hasPrefix("0") ? digits - 1 : digits
    }

    var value: Decimal? {
        if let atomicValue { return atomicValue }
        if isIncomplete { return nil }
        return Decimal(string: text, locale: Locale(identifier: "en_US_POSIX"))
    }

    var displayText: String {
        NumberToken.displayText(for: text)
    }

    // The sign is shown with the same "−" as the subtract operator
    static func displayText(for text: String) -> String {
        text.replacingOccurrences(of: "-", with: "−")
    }

    mutating func setBody(_ newBody: String) {
        text = (isNegative ? "-" : "") + newBody
    }

    mutating func dropLastCharacter() {
        text.removeLast()
    }
}

enum Token: Equatable {
    case number(NumberToken)
    case op(Operator)

    var displayText: String {
        switch self {
        case .number(let number): return number.displayText
        case .op(let op): return op.symbol
        }
    }
}
