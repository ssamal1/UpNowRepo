import SwiftUI

struct ContentView: View {
    @StateObject private var alarmManager = AlarmManager.shared

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(alarmManager.alarms) { alarm in
                        AlarmRow(alarm: alarm, onDelete: {
                            alarmManager.deleteAlarm(alarm)
                        })
                    }
                }
                .navigationTitle("Scheduled Alarms")
                .navigationBarItems(trailing: NavigationLink(destination: AlarmSetupView()) {
                    Image(systemName: "plus")
                })
            }
            .navigationDestination(isPresented: $alarmManager.isAlarmTriggered) {
                AlarmTriggeredView()
            }
        }
    }
}

struct AlarmRow: View {
    var alarm: Alarm
    var onDelete: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(alarm.time, formatter: DateFormatter.timeFormatter)")
                    .font(.headline)
                Text(alarm.repeatInterval.rawValue.capitalized)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer() // Push the delete button to the right
            
            // Delete button
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 8)
    }
}

extension DateFormatter {
    static var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
