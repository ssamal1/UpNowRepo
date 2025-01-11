//
//  AlarmStateManager.swift
//  UpNow
//
//  Created by Sanat Samal on 9/6/24.
//

import Foundation

class AlarmStateManager: ObservableObject {
    static let shared = AlarmStateManager()
    
    var snoozeTime: Int? // Optional snooze time
    var latestPrimerMelody: String? // Optional primer melody    
    // Optionally, add methods to update the primer melody or manage state
}
