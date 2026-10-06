//
//  calculator_appTests.swift
//  calculator_appTests
//
//  Created by Akihiro Yoshida on 2026/10/05.
//

import Foundation
import Testing
@testable import calculator_app

// MARK: - Helpers

private let keysBySymbol: [Character: CalculatorKey] = [
    "0": .zero, "1": .one, "2": .two, "3": .three, "4": .four,
    "5": .five, "6": .six, "7": .seven, "8": .eight, "9": .nine,
    ".": .dot, "=": .equal, "+": .plus, "-": .minus, "*": .multiply, "/": .divide,
    "D": .del, "C": .clear, "A": .allClear, "Z": .doubleZero,
]

// Presses one key per character: digits, ". = + - * /", D = DEL, C = C, A = AC, Z = 00
@MainActor
private func engine(after input: String) -> CalculatorEngine {
    let engine = CalculatorEngine()
    press(input, on: engine)
    return engine
}

@MainActor
private func press(_ input: String, on engine: CalculatorEngine) {
    for character in input {
        engine.press(keysBySymbol[character]!)
    }
}

private func decimal(_ text: String) -> Decimal {
    Decimal(string: text, locale: Locale(identifier: "en_US_POSIX"))!
}

// MARK: - ExpressionEvaluator

@MainActor
struct ExpressionEvaluatorTests {
    private func evaluate(_ input: String) -> Result<Decimal, CalculationError>? {
        let engine = engine(after: input)
        return ExpressionEvaluator.evaluate(engine.tokens)
    }

    @Test func precedence() {
        #expect(evaluate("1+2*3-5/2") == .success(decimal("4.5")))
        #expect(evaluate("2*3+4*5") == .success(26))
        #expect(evaluate("8/2/2") == .success(2))
        #expect(evaluate("10-2-3") == .success(5))
    }

    @Test func negativeNumbers() {
        #expect(evaluate("-5+3") == .success(-2))
        #expect(evaluate("5*-3") == .success(-15))
        #expect(evaluate("5--3") == .success(8))
    }

    @Test func decimals() {
        #expect(evaluate("0.1+0.2") == .success(decimal("0.3")))
        #expect(evaluate("7/2") == .success(decimal("3.5")))
    }

    @Test func divisionByZero() {
        #expect(evaluate("5/0") == .failure(.divisionByZero))
        #expect(evaluate("5/0.0") == .failure(.divisionByZero))
        #expect(evaluate("5/-0") == .failure(.divisionByZero))
        #expect(evaluate("0/0") == .failure(.divisionByZero))
    }

    @Test func overflow() {
        let input = "999999999999999" + String(repeating: "*999999999999999", count: 11)
        #expect(evaluate(input) == .failure(.overflow))
    }

    @Test func underflowBecomesZero() {
        let input = "0.00000000000001" + String(repeating: "/99999999999999", count: 10)
        #expect(evaluate(input) == .success(0))
    }

    @Test func malformedTokensFail() {
        #expect(ExpressionEvaluator.evaluate([]) == .failure(.invalidExpression))
        #expect(ExpressionEvaluator.evaluate([.op(.add)]) == .failure(.invalidExpression))
        #expect(ExpressionEvaluator.evaluate([.number(NumberToken("1")), .op(.add)]) == .failure(.invalidExpression))
        #expect(ExpressionEvaluator.evaluate([.number(NumberToken("-"))]) == .failure(.invalidExpression))
        #expect(ExpressionEvaluator.evaluate([.number(NumberToken("1")), .number(NumberToken("2"))]) == .failure(.invalidExpression))
    }
}

// MARK: - ResultFormatter

@MainActor
struct ResultFormatterTests {
    private func display(_ value: Decimal) -> String {
        ResultFormatter.format(ResultFormatter.round(value))
    }

    @Test func roundsToFifteenSignificantDigits() {
        #expect(display(Decimal(1) / Decimal(3)) == "0.333333333333333")
        #expect(display(Decimal(2) / Decimal(3)) == "0.666666666666667")
        #expect(display(decimal("-33.33333333333333333")) == "-33.3333333333333")
        #expect(display(decimal("0.99999999999999999999999")) == "1")
    }

    @Test func trimsTrailingZeros() {
        #expect(display(decimal("2.500")) == "2.5")
        #expect(display(decimal("3.000")) == "3")
        #expect(display(1500) == "1500")
    }

    @Test func zero() {
        #expect(display(0) == "0")
        #expect(display(decimal("-0")) == "0")
    }

    @Test func exponentNotationBoundaries() {
        #expect(display(decimal("999999999999999")) == "999999999999999")
        #expect(display(decimal("1000000000000000")) == "1e+15")
        #expect(display(decimal("-150000000000000000000")) == "-1.5e+20")
        #expect(display(decimal("0.000001")) == "0.000001")
        #expect(display(decimal("0.0000009")) == "9e-7")
        #expect(display(decimal("0.000000123456")) == "1.23456e-7")
    }

    @Test func roundingCanCarryIntoNextDigit() {
        #expect(display(decimal("9999999999999999")) == "1e+16")
        #expect(display(decimal("0.0000009999999999999999")) == "0.000001")
    }
}

// MARK: - CalculatorEngine: display

@MainActor
struct CalculatorEngineDisplayTests {
    @Test func initialState() {
        let engine = CalculatorEngine()
        #expect(engine.mainLine == "0")
        #expect(engine.subLine == "")
    }

    @Test func editingShowsExpressionOnMainLine() {
        let engine = engine(after: "12+-5")
        #expect(engine.mainLine == "12+−5")
        #expect(engine.subLine == "")
    }

    @Test func resultShowsExpressionOnSubLine() {
        let engine = engine(after: "59-89+20/6=")
        #expect(engine.mainLine == "−26.6666666666667")
        #expect(engine.subLine == "59−89+20÷6")
    }

    @Test func errorMessages() {
        #expect(engine(after: "5/0=").mainLine == "Undefined")
        #expect(engine(after: "5/0=").subLine == "5÷0")
        let overflow = "999999999999999" + String(repeating: "*999999999999999", count: 11) + "="
        #expect(engine(after: overflow).mainLine == "Overflow")
    }
}

// MARK: - CalculatorEngine: input rules

@MainActor
struct CalculatorEngineInputTests {
    @Test(arguments: [
        // Leading zeros and 00
        ("0", "0"), ("05", "5"), ("Z", "0"), ("ZZ", "0"), ("Z5", "5"), ("5Z", "500"),
        ("-0", "−0"), ("-05", "−5"), ("-Z", "−0"),
        // Dot
        (".", "0."), (".5", "0.5"), ("-.", "−0."), ("1.2.3", "1.23"), ("1+.", "1+0."),
        // Minus as sign or operator
        ("-", "−"), ("--", "−"), ("5-", "5−"), ("5--", "5−−"), ("5*-", "5×−"), ("5*--", "5×−"),
        // Other operators
        ("+", "0+"), ("*", "0×"), ("/", "0÷"), ("5+*", "5×"), ("5*-+", "5+"), ("-+", "0+"),
        ("5.+", "5+"), ("5.-", "5−"),
    ])
    func input(keys: String, expected: String) {
        #expect(engine(after: keys).mainLine == expected)
    }

    @Test func digitLimit() {
        let fifteen = "123456789012345"
        #expect(engine(after: fifteen + "6").mainLine == fifteen)
        #expect(engine(after: "12345678901234Z").mainLine == "123456789012340")
        #expect(engine(after: "0." + fifteen + "6").mainLine == "0." + fifteen)
        #expect(engine(after: "-" + fifteen + "6").mainLine == "−" + fifteen)
    }

    @Test(arguments: ["", "12+", "12*-", "0.", "5.", "-0.", "-"])
    func equalIsIgnoredForIncompleteExpressions(keys: String) {
        let engine = engine(after: keys + "=")
        #expect(engine.state == .editing)
        #expect(engine.mainLine == (keys.isEmpty ? "0" : CalculatorEngineInputTests.render(keys)))
    }

    private static func render(_ keys: String) -> String {
        engine(after: keys).mainLine
    }

    @Test func negativeZeroResult() {
        #expect(engine(after: "-0=").mainLine == "0")
    }
}

// MARK: - CalculatorEngine: clear keys (SPEC §4)

@MainActor
struct CalculatorEngineClearTests {
    @Test(arguments: [
        ("12+345", "12+", "12+34"),
        ("12+", "12", "12"),
        ("12*-5", "12×", "12×−"),
        ("12*-", "12×", "12×"),
        ("0.5", "0", "0."),
        ("7", "0", "0"),
        ("", "0", "0"),
    ])
    func clearAndDelete(keys: String, afterClear: String, afterDelete: String) {
        #expect(engine(after: keys + "C").mainLine == afterClear)
        #expect(engine(after: keys + "D").mainLine == afterDelete)
    }

    @Test func allClearFromEveryState() {
        for keys in ["12+3", "12+3=", "5/0="] {
            let engine = engine(after: keys + "A")
            #expect(engine.state == .editing)
            #expect(engine.tokens.isEmpty)
            #expect(engine.mainLine == "0")
        }
    }

    @Test func clearAfterResultOrErrorActsAsAllClear() {
        #expect(engine(after: "1+2=C").tokens.isEmpty)
        #expect(engine(after: "5/0=C").tokens.isEmpty)
    }

    @Test(arguments: [
        ("12+345=", "35"),
        ("3-8=", "−"),
        ("1/2=", "0."),
        ("5-5=", "0"),
        ("1/3=", "0.33333333333333"),
        ("100000000000000*100000=", "0"),
    ])
    func deleteAfterResultCarriesOverAndDeletes(keys: String, expected: String) {
        let engine = engine(after: keys + "D")
        #expect(engine.state == .editing)
        #expect(engine.mainLine == expected)
        #expect(engine.subLine == "")
    }

    @Test func deleteAfterResultBeyondDigitLimit() {
        let engine = engine(after: "1.23456789012345/1000000=")
        #expect(engine.mainLine == "0.00000123456789012345")
        press("D5", on: engine)
        #expect(engine.mainLine == "0.0000012345678901234")
        press("DDDDD5", on: engine)
        #expect(engine.mainLine == "0.000001234567895")
    }

    @Test func deleteAfterErrorActsAsAllClear() {
        #expect(engine(after: "5/0=D").tokens.isEmpty)
    }
}

// MARK: - CalculatorEngine: transitions from result and error (SPEC §5)

@MainActor
struct CalculatorEngineTransitionTests {
    @Test func digitAfterResultStartsNewExpression() {
        #expect(engine(after: "1+2=4").mainLine == "4")
        #expect(engine(after: "1+2=.").mainLine == "0.")
        #expect(engine(after: "1+2=Z").mainLine == "0")
    }

    @Test func operatorAfterResultCarriesOver() {
        #expect(engine(after: "10+5=+").mainLine == "15+")
        #expect(engine(after: "10+5=-").mainLine == "15−")
        #expect(engine(after: "1-5=*2=").mainLine == "−8")
    }

    @Test func carryOverUsesDisplayedValue() {
        #expect(engine(after: "1/3=*3=").mainLine == "0.999999999999999")
    }

    @Test func carriedPlainResultIsEditable() {
        #expect(engine(after: "10+5=+DD").mainLine == "1")
    }

    @Test func carriedExponentResultIsAtomic() {
        let big = "100000000000000*100000="
        #expect(engine(after: big).mainLine == "1e+19")
        #expect(engine(after: big + "+").mainLine == "1e+19+")
        #expect(engine(after: big + "+D").mainLine == "1e+19")
        #expect(engine(after: big + "+D5.").mainLine == "1e+19")
        #expect(engine(after: big + "+DD").mainLine == "0")
        #expect(engine(after: big + "/2=").mainLine == "5e+18")
    }

    @Test func equalAfterResultDoesNothing() {
        let engine = engine(after: "1+2==")
        #expect(engine.mainLine == "3")
        #expect(engine.subLine == "1+2")
    }

    @Test func inputAfterError() {
        #expect(engine(after: "5/0=7").mainLine == "7")
        #expect(engine(after: "5/0=+").mainLine == "0+")
        #expect(engine(after: "5/0=-").mainLine == "−")
        #expect(engine(after: "5/0==").mainLine == "Undefined")
    }
}

// MARK: - Never crash

@MainActor
struct CalculatorEngineRobustnessTests {
    @Test func randomKeyPresses() {
        var generator = SystemRandomNumberGenerator()
        let keys = CalculatorKey.allCases
        for _ in 0..<200 {
            let engine = CalculatorEngine()
            for _ in 0..<200 {
                engine.press(keys.randomElement(using: &generator)!)
                _ = engine.mainLine
                _ = engine.subLine
            }
        }
    }
}
