import Foundation

/// Eine Wasch-Ladung: vom Start des Timers bis zur Foto-Verifikation an der Maschine.
struct LaundrySession: Codable, Identifiable, Hashable {
    enum State: Codable, Hashable {
        /// Countdown läuft.
        case running
        /// Timer abgelaufen, Alarm aktiv, wartet auf Foto-Verifikation.
        case alarming
        /// Per Foto an der Maschine beendet — eine "gerettete Ladung". 🎉
        case verified(at: Date)
        /// Per Notfall-Override beendet (10-Sekunden-Hold, limitiert pro Monat).
        case overridden(at: Date)
        /// Vom User vor Ablauf abgebrochen.
        case cancelled(at: Date)
    }

    let id: UUID
    let machineID: UUID
    let presetMinutes: Int
    let startedAt: Date
    var endsAt: Date
    var state: State

    var remaining: TimeInterval { max(0, endsAt.timeIntervalSinceNow) }

    var isActive: Bool {
        switch state {
        case .running, .alarming: return true
        default: return false
        }
    }

    static func start(machineID: UUID, preset: CyclePreset) -> LaundrySession {
        let now = Date()
        return LaundrySession(
            id: UUID(),
            machineID: machineID,
            presetMinutes: preset.minutes,
            startedAt: now,
            endsAt: now.addingTimeInterval(preset.duration),
            state: .running
        )
    }

    // TODO [WEITERBAUEN]: "+5 min Snooze" als State modellieren (max. 1x, verschiebt endsAt).
    // Snooze ist laut Konzept bewusst auf 5 Minuten begrenzt.
}
