//
//  ContentView.swift
//  aparcabicis4
//
//  Created by Francisco Díaz on 13/10/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "bicycle.circle.fill")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Aparcabicis en mi Ciudad")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
