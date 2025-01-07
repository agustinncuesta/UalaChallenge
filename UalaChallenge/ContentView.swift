//
//  ContentView.swift
//  UalaChallenge
//
//  Created by Agustin Nicolas Cuesta on 04/01/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    var body: some View {
        CityListView()
    }
    
}

#Preview {
    ContentView()
        .modelContainer(for: CityLocalModel.self, inMemory: true)
}
