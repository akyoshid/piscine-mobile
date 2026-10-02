//
//  ContentView.swift
//  ex01
//
//  Created by Akihiro Yoshida on 2026/10/03.
//

import SwiftUI

struct ContentView: View {
    @State private var sayingHello = false
    
    var body: some View {
        VStack {
            Text(sayingHello ? "Hello World!" : "A simple text")
            Button("Click me") {
                print("Button pressed")
                sayingHello.toggle()
            }
            .buttonStyle(.glassProminent)
        }
    }
}

#Preview {
    ContentView()
}
