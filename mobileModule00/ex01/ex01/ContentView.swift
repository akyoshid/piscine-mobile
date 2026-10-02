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
            Text("Hello, world!")
            Button("Click") {
                print("Button pressed")
            }
            .buttonStyle(.glassProminent)
        }
    }
}

#Preview {
    ContentView()
}
