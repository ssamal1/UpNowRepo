import SwiftUI

struct AlarmSetupView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var alarmTime = Date()
    @State private var repeatInterval: RepeatInterval = .none

    var body: some View {
        VStack {
            DatePicker("Select Alarm Time", selection: $alarmTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .padding()

            Picker("Repeat Interval", selection: $repeatInterval) {
                Text("None").tag(RepeatInterval.none)
                Text("Daily").tag(RepeatInterval.daily)
                Text("Weekly").tag(RepeatInterval.weekly)
                Text("Monthly").tag(RepeatInterval.monthly)
                Text("Yearly").tag(RepeatInterval.yearly)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            Button(action: {
                // Save the alarm time and schedule the alarm using AlarmManager
                AlarmManager.shared.scheduleAlarm(at: alarmTime, repeatInterval: repeatInterval)
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Set Alarm")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

struct AlarmSetupView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmSetupView()
    }
}
