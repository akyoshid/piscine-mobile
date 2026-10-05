//
//  CalculatorKey.swift
//  calculator_app
//
//  Created by Akihiro Yoshida on 2026/10/03.
//

enum CalculatorKey: CaseIterable {
    case doubleZero, zero, one, two, three, four, five, six, seven, eight, nine
    case dot
    case equal, plus, minus, multiply, divide
    case del, clear, allClear

    var label: String {
        switch self {
        case .doubleZero: return "00"
        case .zero: return "0"
        case .one: return "1"
        case .two: return "2"
        case .three: return "3"
        case .four: return "4"
        case .five: return "5"
        case .six: return "6"
        case .seven: return "7"
        case .eight: return "8"
        case .nine: return "9"
        case .dot: return "."
        case .equal: return "="
        case .plus: return "+"
        case .minus: return "−"
        case .multiply: return "×"
        case .divide: return "÷"
        case .del: return "DEL"
        case .clear: return "C"
        case .allClear: return "AC"
        }
    }

    var mathOperator: Operator? {
        switch self {
        case .plus: return .add
        case .minus: return .subtract
        case .multiply: return .multiply
        case .divide: return .divide
        default: return nil
        }
    }

    func isNumeric() -> Bool {
        switch self {
        case .doubleZero, .zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine:
            return true
        default:
            return false
        }
    }

    func isOperator() -> Bool {
        switch self {
        case .equal, .plus, .minus, .multiply, .divide:
            return true
        default:
            return false
        }
    }

    func isDelete() -> Bool {
        switch self {
        case .del, .clear, .allClear:
            return true
        default:
            return false
        }
    }

    static let portraitRows: [[CalculatorKey]] = [
        [.del, .clear, .allClear, .divide],
        [.seven, .eight, .nine, .multiply],
        [.four, .five, .six, .minus],
        [.one, .two, .three, .plus],
        [.doubleZero, .zero, .dot, .equal],
    ]
    static let landscapeRows: [[CalculatorKey]] = [
        [.seven, .eight, .nine, .del, .divide],
        [.four, .five, .six, .clear, .multiply],
        [.one, .two, .three, .allClear, .minus],
        [.doubleZero, .zero, .dot, .equal, .plus],
    ]
}
