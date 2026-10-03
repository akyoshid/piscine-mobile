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
    let isWide: Bool

    var body: some View {
        VStack(alignment: .trailing, spacing: isWide ? 0: 8) {
            ScrollView(.horizontal) {
                Text(expression)
                    .font(.system(size: isWide ? 18 : 28, weight: .regular))
                    .foregroundStyle(.secondary)
            }
            ScrollView(.horizontal) {
                Text(result)
                    .font(.system(size: isWide ? 40 : 56, weight: .regular))
                    .foregroundStyle(.primary)
                    .textSelection(.enabled)
            }
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
        .defaultScrollAnchor(.trailing)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.bottom, isWide ? 10 : 20)
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

struct CalculatorKeyStyle: ButtonStyle {
    var key: CalculatorKey
    let isWide: Bool
    
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
    
    var shape: AnyShape {
        isWide ? AnyShape(Capsule()) : AnyShape(Circle())
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: isWide ? 28 : 36, weight: .regular))
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(shape)
            .glassEffect(glass, in: shape)
    }

    init(_ key: CalculatorKey, isWide: Bool) {
        self.key = key
        self.isWide = isWide
    }
}

struct CalculatorButton: View {
    let key: CalculatorKey
    let isWide: Bool

    var body: some View {
        Button() {
            print("button pressed: \(key.label)")
        } label: {
            if key == .del {
                Image(systemName: "delete.backward")
            } else {
                Text(key.label)
            }
        }
        .buttonStyle(CalculatorKeyStyle(key, isWide: isWide))
    }

    init(_ key: CalculatorKey, isWide: Bool) {
        self.key = key
        self.isWide = isWide
    }
}

struct CalculatorKeypad: View {
    let isWide: Bool

    var rows: [[CalculatorKey]] {
        isWide ? CalculatorKey.landscapeRows : CalculatorKey.portraitRows
    }

    var body: some View {
        if isWide {
            keypad
        } else {
            keypad.aspectRatio(4.0 / 5.0, contentMode: .fit)
        }
    }

    private var keypad: some View {
        GlassEffectContainer {
            Grid(horizontalSpacing: 10, verticalSpacing: 10) {
                ForEach(rows, id: \.self) { row in
                    GridRow {
                        ForEach(row, id: \.self) {
                            CalculatorButton($0, isWide: isWide)
                        }
                    }
                }
            }
        }
    }
}

struct ContentView: View {
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                let isWide = geo.size.width > geo.size.height
                VStack(spacing: 0) {
                    if !isWide {
                        Spacer(minLength: 0)
                    }
                    CalculatorDisplay(isWide: isWide)
                    CalculatorKeypad(isWide: isWide)
                }
                .padding(isWide ? [.bottom, .horizontal] : .all, 20)
            }
            .navigationTitle("Calculator")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ContentView()
}
