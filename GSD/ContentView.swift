//
//  ContentView.swift
//  GSD
//
//  Created by Asaf Navon on 5/15/25.
//

import SwiftUI
import SwiftData

enum TimerState {
    case ready
    case work
    case breakTime
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    @State private var timerState: TimerState = .ready
    @State private var percent: CGFloat = 0
    @State private var sessionCount: Int = 1
    @State private var timeInMillis: Int = 0
    @State private var elapsedTimeInMillis: Int = 0
    @State private var timer: Timer? = nil

    var body: some View {
        VStack {
            Spacer()

            ZStack {
                // Background Ring
                ProgressRing(
                    ringWidth: 20, percent: percent,
                    backgroundColor: ringBackgroundColor(),
                    foregroundColors: [ringForegroundColor().opacity(1.0 - min(percent / 100, 1.0) * 0.5), ringForegroundColor()]
                )
                .frame(width: 300, height: 300)
                .padding(10)
                .overlay(
                    VStack {
                        Text(timerText())
                            .font(.largeTitle)
                        if(timerState != .ready){
                            Text(remainingTimeText(millis: timeInMillis-elapsedTimeInMillis))
                                .font(.largeTitle)
                        }
                    }
                )
            }


            // Session Count
            Text("Session \(sessionCount)")
                .foregroundColor(.gray)
                .font(.headline)
                .padding(10)


            // Action Buttons
            HStack(spacing: 20) {
                ActionButton(title: buttonText(), color: buttonColor()) {
                    handleButtonTap()
                }
                if(timerState != .ready){
                    ActionButton(title: "end_session_button_text", color: .electricBlue) {
                        endSession()
                    }
                }
            }.padding(20)

            Spacer()
        }
    }

    // MARK: - Functions

    func startTimer() {
        timer?.invalidate() // stop old timer if any
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            timer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { _ in
                elapsedTimeInMillis += 1
                percent = CGFloat(Float(elapsedTimeInMillis) / Float(timeInMillis) * 100)
            }
        }
        
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func handleButtonTap() {
        stopTimer()
        elapsedTimeInMillis = 0
        withAnimation{
            switch timerState {
            case .ready, .breakTime:
                timerState = .work
                timeInMillis = 10 * 1000
                sessionCount += 1
                startTimer()
            case .work:
                timerState = .breakTime
                timeInMillis = 3 * 1000
                startTimer()
            }
        }
    }

    func endSession() {
        withAnimation {
            timerState = .ready
            percent = 0
            sessionCount = 1
        }
        stopTimer()
    }

    func ringBackgroundColor() -> Color {
        return switch timerState {
        case .ready: .gunmetal
        case .work: .neonGreen.opacity(0.3)
        case .breakTime: .crimsonRed.opacity(0.3)
        }
    }
    
    func ringForegroundColor() -> Color {
        return switch timerState {
        case .ready: .gunmetal
        case .work: .neonGreen
        case .breakTime: .crimsonRed
        }
    }
    
    func buttonColor() -> Color {
        return switch timerState {
        case .ready, .breakTime: .neonGreen
        case .work: .crimsonRed
        }
    }
    
    func buttonText() -> LocalizedStringKey {
        return switch timerState {
        case .ready: "start_a_work_session_button_text"
        case .work: "take_a_break_button_text"
        case .breakTime: "get_back_to_work_button_text"
        }
    }

    func timerText() -> LocalizedStringKey {
        return switch timerState {
        case .ready: "idle_message"
        case .work: "work_message"
        case .breakTime: "break_message"
        }
    }

    func remainingTimeText(millis: Int) -> String {
        let seconds = millis > 0 ? millis / 1000 + 1 : millis / 1000
        let hours = seconds / 3600
        let mins = seconds % 3600 / 60
        let secs = seconds % 60
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", abs(hours), abs(mins), abs(secs))
        } else{
            return String(format: "%02d:%02d", abs(mins), abs(secs))
        }
    }
}

struct ActionButton: View {
    var title: LocalizedStringKey
    var color: Color
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Capsule()
                .frame(height: 60)
                .foregroundColor(.gunmetal)
                .overlay(Capsule().stroke(color, lineWidth: 3))
                .overlay(Text(title).font(.headline).foregroundStyle(.pureWhite))
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
