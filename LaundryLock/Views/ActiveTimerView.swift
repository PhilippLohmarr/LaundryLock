import SwiftUI

/// MVP-Screen 3: Laufender Countdown mit Abbrechen-Option.
struct ActiveTimerView: View {
    @Environment(AppModel.self) private var model

    /// Tickt sekündlich für die Anzeige; der eigentliche Alarm läuft unabhängig
    /// davon über den AlarmService (funktioniert also auch bei geschlossener App).
    @State private var now = Date()
    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            if let session = model.activeSession {
                Text("Wäsche läuft…")
                    .font(.title2.weight(.semibold))

                countdownRing(session)

                Text("Endet um \(session.endsAt.formatted(date: .omitted, time: .shortened))")
                    .foregroundStyle(.secondary)

                Spacer()

                Button(role: .destructive) {
                    Task { await model.cancelActiveLoad() }
                } label: {
                    Text("Abbrechen").frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .padding(.horizontal)

                // TODO [WEITERBAUEN]: "+5 min"-Button (einmaliger Snooze laut Konzept),
                // verschiebt endsAt und plant den Alarm im AlarmService um.
            }

            Spacer()
        }
        .padding()
        .onReceive(ticker) { time in
            now = time
            model.markAlarming() // Zustandswechsel, sobald der Countdown abläuft
        }
        // TODO [WEITERBAUEN]: Dieser Screen wird größtenteils obsolet, sobald die
        // Live Activity steht — der Countdown gehört auf Lock Screen & Dynamic Island.
    }

    private func countdownRing(_ session: LaundrySession) -> some View {
        let total = TimeInterval(session.presetMinutes * 60)
        let progress = max(0, min(1, 1 - session.remaining / total))

        return ZStack {
            Circle()
                .stroke(.indigo.opacity(0.15), lineWidth: 14)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(.indigo, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text(formatted(session.remaining))
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText())
        }
        .frame(width: 240, height: 240)
        .animation(.linear(duration: 1), value: progress)
    }

    private func formatted(_ interval: TimeInterval) -> String {
        let seconds = Int(interval)
        return String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}

#Preview {
    ActiveTimerView().environment(AppModel())
}
