//
//  TestView.swift
//  UpNow
//
//  Created by Sanat Samal on 9/6/24.
//

import Foundation
import SwiftUI

struct TestView: View {
    @StateObject private var qLearningAgent = QLearningAgent(stateSize: 10, actionSize: 5)
    @State private var generatedMelody: String = "No melody generated yet."
    
    var body: some View {
        VStack {
            Button(action: runQLearning) {
                Text("Run Q-Learning")
                    .font(.title)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            Text("Generated Melody:")
                .font(.headline)
                .padding()
            
            Text(generatedMelody)
                .font(.body)
                .padding()
                .multilineTextAlignment(.center)
        }
        .onAppear {
            // Initialize AlarmStateManager with default values if needed
            AlarmStateManager.shared.snoozeTime = 30 // Example snooze time
            AlarmStateManager.shared.latestPrimerMelody = "60, -2, 62, -2, 64, -2, 65, -2" // Example melody
        }
    }
    
    private func runQLearning() {
        qLearningAgent.trainAndUpdatePrimerMelody()
        
        // Get the updated melody from AlarmStateManager
        generatedMelody = AlarmStateManager.shared.latestPrimerMelody ?? "No melody available."
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
