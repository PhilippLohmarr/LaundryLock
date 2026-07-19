import SwiftUI

/// MVP-Screen 5a: Verlauf — gerettete Ladungen, Overrides, Abbrüche.
struct HistoryView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        List {
            if model.sessions.isEmpty {
                ContentUnavailableView(
                    "Noch keine Wäsche",
                    systemImage: "washer",
                    description: Text("Starte deine erste Ladung auf dem Home-Screen.")
                )
            }
            ForEach(model.sessions) { session in
                HStack {
                    Image(systemName: icon(for: session.state))
                        .foregroundStyle(color(for: session.state))
                    VStack(alignment: .leading) {
                        Text(title(for: session.state)).font(.body)
                        Text("\(session.presetMinutes) min · \(session.startedAt.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Verlauf")
        // TODO [WEITERBAUEN]: Wochen-Zusammenfassung oben anpinnen ("3 Ladungen diese
        // Woche gerettet") mit ShareLink — der virale Hook aus dem Konzept.
    }

    private func title(for state: LaundrySession.State) -> String {
        switch state {
        case .running: "Läuft gerade"
        case .alarming: "Alarm aktiv"
        case .verified: "Gerettet ✅"
        case .overridden: "Notfall-Override"
        case .cancelled: "Abgebrochen"
        }
    }

    private func icon(for state: LaundrySession.State) -> String {
        switch state {
        case .running: "timer"
        case .alarming: "bell.badge.fill"
        case .verified: "checkmark.seal.fill"
        case .overridden: "exclamationmark.triangle.fill"
        case .cancelled: "xmark.circle"
        }
    }

    private func color(for state: LaundrySession.State) -> Color {
        switch state {
        case .running, .alarming: .indigo
        case .verified: .green
        case .overridden: .orange
        case .cancelled: .secondary
        }
    }
}

#Preview {
    NavigationStack { HistoryView() }.environment(AppModel())
}
