//
//  UpNowApp.swift
//  UpNow
//
//  Created by Sanat Samal on 7/8/24.
//

// UpNowApp.swift
// UpNowApp.swift
import SwiftUI
import UserNotifications

@main
struct UpNowApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear(perform: requestNotificationPermissions)
        }
    }

    func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notifications permission granted")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            } else {
                print("Notifications permission not granted")
            }
        }
    }
}
