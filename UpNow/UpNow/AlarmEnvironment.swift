//
//  AlarmEnvironment.swift
//  UpNow
//
//  Created by Sanat Samal on 9/6/24.
//

import Foundation

class AlarmEnvironment {
    private(set) var state: Int
    
    // Initializer for AlarmEnvironment
    init() {
        self.state = 0  // Initialize state to a default value
    }
    
    func reset() -> Int {
        // Initialize state
        self.state = 0  // Reset state to the initial value
        return self.state
    }
    
    func step(action: Int) -> (nextState: Int, reward: Double, done: Bool) {
        // Generate melody based on action
        let melody = decodeAction(action)
        let snoozeTime = simulateAlarm(melody)
        let reward = -snoozeTime
        let done = false
        return (state, reward, done)
    }
    
    private func decodeAction(_ action: Int) -> [Int] {
        // Convert action to melody format
        return [60, -2, 60, -2, 67, -2, 67, -2]
    }
    
    private func simulateAlarm(_ melody: [Int]) -> Double {
        // Simulate snooze time
        return Double.random(in: 1..<10)  // Example snooze time
    }
}
