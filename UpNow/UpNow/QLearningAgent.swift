import Foundation

class QLearningAgent: ObservableObject {
    @Published private(set) var qTable: [String: [Double]] // Q-table
    private let learningRate: Double
    private let discountFactor: Double
    private var explorationRate: Double
    private let explorationDecay: Double
    
    private let stateSize: Int
    private let actionSize: Int

    init(stateSize: Int, actionSize: Int, learningRate: Double = 0.1, discountFactor: Double = 0.9, explorationRate: Double = 1.0, explorationDecay: Double = 0.995) {
        self.stateSize = stateSize
        self.actionSize = actionSize
        self.learningRate = learningRate
        self.discountFactor = discountFactor
        self.explorationRate = explorationRate
        self.explorationDecay = explorationDecay
        self.qTable = [:]
    }

    func trainAndUpdatePrimerMelody() {
        guard let snoozeTime = AlarmStateManager.shared.snoozeTime,
              let previousPrimerMelody = AlarmStateManager.shared.latestPrimerMelody else {
            print("Error: Snooze time or primer melody is missing")
            return
        }
        
        let state = getStateRepresentation(snoozeTime: snoozeTime, primerMelody: previousPrimerMelody)
        let action = chooseAction(state: state)
        let reward = calculateReward(for: snoozeTime)
        let nextState = getNextState(for: action, currentState: state)
        
        updateQTable(state: state, action: action, reward: reward, nextState: nextState)
        generateAndUpdatePrimerMelody()
        decayExplorationRate()
    }

    private func getStateRepresentation(snoozeTime: Int, primerMelody: String) -> String {
        let melodyHash = primerMelody.hashValue
        return "\(snoozeTime)_\(melodyHash)"
    }

    private func calculateReward(for snoozeTime: Int) -> Double {
        let maxSnoozeTime = 60 // Assume 60 seconds is the maximum snooze time
        let reward = max(0.0, 1.0 - (Double(snoozeTime) / Double(maxSnoozeTime)))
        return reward
    }

    private func getNextState(for action: Int, currentState: String) -> String {
        let components = currentState.split(separator: "_")
        
        guard components.count == 2,
              let currentSnoozeTime = Int(components[0]),
              let currentMelodyHash = Int(components[1]) else {
            return currentState // Return current state if parsing fails
        }
        
        // Simulate snooze time change based on action
        let newSnoozeTime = max(0, currentSnoozeTime - action)
        
        // Simulate melody change (simplified)
        let newMelodyHash = (currentMelodyHash + action).hashValue
        
        return "\(newSnoozeTime)_\(newMelodyHash)"
    }

    func generateAndUpdatePrimerMelody() {
        let primerMelody = getPrimerMelody()
        AlarmStateManager.shared.latestPrimerMelody = primerMelody
    }

    func getPrimerMelody() -> String {
        guard let snoozeTime = AlarmStateManager.shared.snoozeTime else {
            return "60, -2, 62, -2, 64, -2, 65, -2" // Default melody if no snooze time
        }
        
        let state = getStateRepresentation(snoozeTime: snoozeTime, primerMelody: AlarmStateManager.shared.latestPrimerMelody ?? "")
        let bestAction = chooseAction(state: state)
        
        // Generate melody based on the best action
        let baseMelody = [60, 62, 64, 65, 67, 69, 71, 72]
        var newMelody = [Int]()
        
        for _ in 0..<4 {
            let note = baseMelody[bestAction % baseMelody.count]
            newMelody.append(note)
            newMelody.append(-2) // Rest
        }
        
        return newMelody.map { String($0) }.joined(separator: ", ")
    }

    func updateQTable(state: String, action: Int, reward: Double, nextState: String) {
        if qTable[state] == nil {
            qTable[state] = Array(repeating: 0.0, count: actionSize)
        }
        if qTable[nextState] == nil {
            qTable[nextState] = Array(repeating: 0.0, count: actionSize)
        }
        
        let oldValue = qTable[state]?[action] ?? 0.0
        let nextMax = qTable[nextState]?.max() ?? 0.0
        let newValue = oldValue + learningRate * (reward + discountFactor * nextMax - oldValue)
        qTable[state]?[action] = newValue
    }

    func chooseAction(state: String) -> Int {
        if Double.random(in: 0..<1) < explorationRate {
            return Int.random(in: 0..<actionSize)
        } else {
            let actions = qTable[state] ?? Array(repeating: 0.0, count: actionSize)
            return actions.indices.max(by: { actions[$0] < actions[$1] }) ?? 0
        }
    }

    func decayExplorationRate() {
        explorationRate *= explorationDecay
    }
}
