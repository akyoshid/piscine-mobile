//
//  ContentView.swift
//  ex02
//
//  Created by Akihiro Yoshida on 2026/10/03.
//

import SwiftUI

struct CalculatorDisplay: View {
    let expression = "2,222,222+2,222,222"
    let result = "4,444,444"

    var body: some View {
        VStack(alignment: .trailing) {
            ScrollView(.horizontal) {
                Text(expression)
                    .font(.system(size: 28, weight: .regular))
                    .foregroundStyle(.secondary)
            }
            ScrollView(.horizontal) {
                Text(result)
                    .font(.system(size: 56, weight: .regular))
                    .foregroundStyle(.primary)
                    .textSelection(.enabled)
            }
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
        .defaultScrollAnchor(.trailing)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.vertical, 20)
    }
}

enum CalculatorKey: CaseIterable {
    case doubleZero, zero, one, two, three, four, five, six, seven, eight, nine
    case dot
    case equal, plus, minus, multiply, divide
    case del, clear, allClear
    
    var value: Int? {
        switch self {
        case .zero: return 0
        case .one: return 1
        case .two: return 2
        case .three: return 3
        case .four: return 4
        case .five: return 5
        case .six: return 6
        case .seven: return 7
        case .eight: return 8
        case .nine: return 9
        default: return nil
        }
    }
    
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
}

struct CalculatorKeyStyle: ButtonStyle {
    var key: CalculatorKey
    
    var foreground: Color {
        if key.isOperator() {
            .white
        } else {
            .primary
        }
    }
    
    var glass: Glass {
        if key.isOperator() {
            .regular.tint(.orange).interactive()
        } else if key.isDelete() {
            .regular.tint(.gray.opacity(0.3)).interactive()
        } else {
            .regular.interactive()
        }
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 36, weight: .regular))
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .contentShape(Circle())
            .glassEffect(glass, in: .circle)
    }
    
    init(_ key: CalculatorKey) {
        self.key = key
    }
}

struct CalculatorButton: View {
    let key: CalculatorKey
    
    var body: some View {
        Button(action: {}) {
            if key == .del {
                Image(systemName: "delete.backward")
            } else {
                Text(key.label)
            }
        }
        .buttonStyle(CalculatorKeyStyle(key))
    }
    
    init(_ key: CalculatorKey) {
        self.key = key
    }
}

struct CalculatorKeypad: View {
    var body: some View {
        GlassEffectContainer {
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    CalculatorButton(.del)
                    CalculatorButton(.clear)
                    CalculatorButton(.allClear)
                    CalculatorButton(.divide)
                }
                HStack(spacing: 10) {
                    CalculatorButton(.seven)
                    CalculatorButton(.eight)
                    CalculatorButton(.nine)
                    CalculatorButton(.multiply)
                }
                HStack(spacing: 10) {
                    CalculatorButton(.four)
                    CalculatorButton(.five)
                    CalculatorButton(.six)
                    CalculatorButton(.minus)
                }
                HStack(spacing: 10) {
                    CalculatorButton(.one)
                    CalculatorButton(.two)
                    CalculatorButton(.three)
                    CalculatorButton(.plus)
                }
                HStack(spacing: 10) {
                    CalculatorButton(.doubleZero)
                    CalculatorButton(.zero)
                    CalculatorButton(.dot)
                    CalculatorButton(.equal)
                }
            }
        }
    }
}

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                CalculatorDisplay()
                CalculatorKeypad()
            }
            .padding(20)
            .navigationTitle("Calculator")
        }
    }
}

#Preview {
    ContentView()
}
