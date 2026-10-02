//
//  ContentView.swift
//  ex00
//
//  Created by Akihiro Yoshida on 2026/10/02.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("A simple text")
            Button("Click me") {
                print("Button pressed")
            }
            .buttonStyle(.glassProminent)
        }
    }
}

#Preview {
    ContentView()
}
