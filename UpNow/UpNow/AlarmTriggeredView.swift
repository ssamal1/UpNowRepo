import SwiftUI

struct AlarmTriggeredView: View {
    @State private var timeRemaining: Int = 60 // 1 minute timer
    @State private var isTimerActive: Bool = true
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("Alarm is Ringing!")
                .font(.largeTitle)
                .foregroundColor(.red)
                .padding()
            
            Text("Time remaining: \(timeRemaining) seconds")
                .font(.headline)
                .foregroundColor(.gray)
                .padding()

            Spacer()
            
            Button(action: stopAlarm) {
                Text("Stop Alarm")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .padding()
        }
        .onAppear(perform: startTimer)
    }
    
    func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if self.timeRemaining > 0 && self.isTimerActive {
                self.timeRemaining -= 1
            } else {
                timer.invalidate()
                stopAlarm()
            }
        }
    }
    
    func stopAlarm() {
        // Stop the alarm audio
        SoundGeneration.shared.stopAudio()
        
        // Log snooze time to shared state manager
        let snoozeTime = 60 - timeRemaining
        AlarmStateManager.shared.snoozeTime = snoozeTime
        

        self.isTimerActive = false
        self.presentationMode.wrappedValue.dismiss() // Dismisses the view
    }
}

struct AlarmTriggeredView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmTriggeredView()
    }
}
