//
//  ExpressionEvaluator.swift
//  calculator_app
//
//  Created by Akihiro Yoshida on 2026/10/05.
//

import Foundation

enum CalculationError: Error, Equatable {
    case divisionByZero
    case overflow
    case invalidExpression

    var message: String {
        switch self {
        case .divisionByZero: return "Undefined"
        case .overflow: return "Overflow"
        case .invalidExpression: return "Error"
        }
    }
}

enum ExpressionEvaluator {
    // Evaluates "number (operator number)*" with × and ÷ before + and −, left to right
    static func evaluate(_ tokens: [Token]) -> Result<Decimal, CalculationError> {
        do {
            let value = try evaluateTokens(tokens)
            return value.isNaN ? .failure(.invalidExpression) : .success(value)
        } catch let error as CalculationError {
            return .failure(error)
        } catch {
            return .failure(.invalidExpression)
        }
    }

    private static func evaluateTokens(_ tokens: [Token]) throws -> Decimal {
        guard tokens.count % 2 == 1 else { throw CalculationError.invalidExpression }

        var total = Decimal(0)
        var pendingOperator = Operator.add
        var term = try number(at: 0, in: tokens)

        for index in stride(from: 1, to: tokens.count, by: 2) {
            guard case .op(let op) = tokens[index] else {
                throw CalculationError.invalidExpression
            }
            let operand = try number(at: index + 1, in: tokens)
            if op.hasHighPrecedence {
                term = try apply(op, term, operand)
            } else {
                total = try apply(pendingOperator, total, term)
                pendingOperator = op
                term = operand
            }
        }
        return try apply(pendingOperator, total, term)
    }

    private static func number(at index: Int, in tokens: [Token]) throws -> Decimal {
        guard case .number(let number) = tokens[index], let value = number.value else {
            throw CalculationError.invalidExpression
        }
        return value
    }

    static func apply(_ op: Operator, _ lhs: Decimal, _ rhs: Decimal) throws -> Decimal {
        if op == .divide && rhs.isZero {
            throw CalculationError.divisionByZero
        }
        var left = lhs
        var right = rhs
        var result = Decimal()
        let status: NSDecimalNumber.CalculationError
        switch op {
        case .add: status = NSDecimalAdd(&result, &left, &right, .plain)
        case .subtract: status = NSDecimalSubtract(&result, &left, &right, .plain)
        case .multiply: status = NSDecimalMultiply(&result, &left, &right, .plain)
        case .divide: status = NSDecimalDivide(&result, &left, &right, .plain)
        }
        switch status {
        case .noError, .lossOfPrecision:
            return result
        case .underflow:
            return 0
        case .overflow:
            throw CalculationError.overflow
        case .divideByZero:
            throw CalculationError.divisionByZero
        @unknown default:
            throw CalculationError.invalidExpression
        }
    }
}
