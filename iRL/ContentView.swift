//
//  ContentView.swift
//  iRL
//
//  Created by delina on 7/31/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppStateManager()
    
    var body: some View {
        Group {
            if appState.hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .environmentObject(appState)
    }
}

#Preview {
    ContentView()
}
