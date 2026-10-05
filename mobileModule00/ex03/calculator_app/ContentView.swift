//
//  ContentView.swift
//  calculator_app
//
//  Created by Akihiro Yoshida on 2026/10/03.
//

import SwiftUI

struct CalculatorDisplay: View {
    let mainLine: String
    let subLine: String
    let isWide: Bool

    var body: some View {
        VStack(alignment: .trailing, spacing: isWide ? 0: 8) {
            ScrollView(.horizontal) {
                // A space keeps the line's height while it is empty
                Text(subLine.isEmpty ? " " : subLine)
                    .font(.system(size: isWide ? 18 : 28, weight: .regular))
                    .foregroundStyle(.secondary)
            }
            ScrollView(.horizontal) {
                Text(mainLine)
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
    let onPress: (CalculatorKey) -> Void

    var body: some View {
        Button() {
            print("button pressed: \(key.label)")
            onPress(key)
        } label: {
            if key == .del {
                Image(systemName: "delete.backward")
            } else {
                Text(key.label)
            }
        }
        .buttonStyle(CalculatorKeyStyle(key, isWide: isWide))
    }

    init(_ key: CalculatorKey, isWide: Bool, onPress: @escaping (CalculatorKey) -> Void) {
        self.key = key
        self.isWide = isWide
        self.onPress = onPress
    }
}

struct CalculatorKeypad: View {
    let isWide: Bool
    let onPress: (CalculatorKey) -> Void

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
                            CalculatorButton($0, isWide: isWide, onPress: onPress)
                        }
                    }
                }
            }
        }
    }
}

struct ContentView: View {
    @State private var engine = CalculatorEngine()

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                let isWide = geo.size.width > geo.size.height
                VStack(spacing: 0) {
                    if !isWide {
                        Spacer(minLength: 0)
                    }
                    CalculatorDisplay(
                        mainLine: engine.mainLine,
                        subLine: engine.subLine,
                        isWide: isWide
                    )
                    CalculatorKeypad(isWide: isWide) { engine.press($0) }
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
