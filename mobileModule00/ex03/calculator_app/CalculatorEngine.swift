//
//  CalculatorEngine.swift
//  calculator_app
//
//  Created by Akihiro Yoshida on 2026/10/05.
//

import Foundation
import Observation

@Observable
final class CalculatorEngine {
    enum State: Equatable {
        case editing
        case showingResult(Decimal)
        case error(CalculationError)
    }

    private(set) var tokens: [Token] = []
    private(set) var state: State = .editing

    var expressionText: String {
        tokens.map(\.displayText).joined()
    }

    var mainLine: String {
        switch state {
        case .editing: return tokens.isEmpty ? "0" : expressionText
        case .showingResult(let value): return NumberToken.displayText(for: ResultFormatter.format(value))
        case .error(let error): return error.message
        }
    }

    var subLine: String {
        state == .editing ? "" : expressionText
    }

    func press(_ key: CalculatorKey) {
        switch key {
        case .doubleZero, .zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine:
            inputDigits(key.label)
        case .dot:
            inputDot()
        case .plus, .minus, .multiply, .divide:
            if let op = key.mathOperator { inputOperator(op) }
        case .equal:
            evaluate()
        case .allClear:
            allClear()
        case .clear:
            clear()
        case .del:
            delete()
        }
    }

    // MARK: - Input

    private func inputDigits(_ digits: String) {
        startNewExpressionIfNeeded()
        guard case .number(var number) = tokens.last else {
            tokens.append(.number(NumberToken(digits == "00" ? "0" : digits)))
            return
        }
        if number.isAtomic { return }
        if number.body.isEmpty || number.body == "0" {
            // Replace a leading zero instead of appending to it
            number.setBody(digits == "00" ? "0" : digits)
        } else {
            let remaining = NumberToken.maxDigits - number.digitCount
            guard remaining > 0 else { return }
            number.setBody(number.body + String(digits.prefix(remaining)))
        }
        tokens[tokens.count - 1] = .number(number)
    }

    private func inputDot() {
        startNewExpressionIfNeeded()
        guard case .number(var number) = tokens.last else {
            tokens.append(.number(NumberToken("0.")))
            return
        }
        if number.isAtomic || number.hasDot { return }
        number.setBody(number.body.isEmpty ? "0." : number.body + ".")
        tokens[tokens.count - 1] = .number(number)
    }

    private func inputOperator(_ op: Operator) {
        switch state {
        case .editing:
            break
        case .showingResult(let value):
            carryOver(value)
        case .error:
            allClear()
        }

        switch tokens.last {
        case nil:
            if op == .subtract {
                tokens.append(.number(NumberToken("-")))
            } else {
                tokens.append(contentsOf: [.number(NumberToken("0")), .op(op)])
            }
        case .op:
            if op == .subtract {
                tokens.append(.number(NumberToken("-")))
            } else {
                tokens[tokens.count - 1] = .op(op)
            }
        case .number(var number):
            if number.body.isEmpty {
                // A lone "-": "−" is ignored, other operators replace the previous one
                if op == .subtract { return }
                tokens.removeLast()
                inputOperator(op)
                return
            }
            if number.body.hasSuffix(".") {
                number.dropLastCharacter()
                tokens[tokens.count - 1] = .number(number)
            }
            tokens.append(.op(op))
        }
    }

    private func evaluate() {
        guard state == .editing,
              case .number(let number) = tokens.last,
              !number.isIncomplete else { return }
        switch ExpressionEvaluator.evaluate(tokens) {
        case .success(let value):
            state = .showingResult(ResultFormatter.round(value))
        case .failure(let error):
            state = .error(error)
        }
    }

    // MARK: - Clear

    private func allClear() {
        tokens = []
        state = .editing
    }

    private func clear() {
        guard state == .editing else { return allClear() }
        if !tokens.isEmpty { tokens.removeLast() }
    }

    private func delete() {
        switch state {
        case .editing:
            break
        case .showingResult(let value):
            carryOver(value)
        case .error:
            return allClear()
        }
        switch tokens.last {
        case nil:
            return
        case .op:
            tokens.removeLast()
        case .number(var number):
            if number.isAtomic {
                tokens.removeLast()
                return
            }
            number.dropLastCharacter()
            if number.text.isEmpty {
                tokens.removeLast()
            } else {
                tokens[tokens.count - 1] = .number(number)
            }
        }
    }

    // Starts a new expression whose first number token is the displayed result
    private func carryOver(_ value: Decimal) {
        let carried = NumberToken(carrying: value, formatted: ResultFormatter.format(value))
        tokens = [.number(carried)]
        state = .editing
    }

    private func startNewExpressionIfNeeded() {
        if state != .editing { allClear() }
    }
}
