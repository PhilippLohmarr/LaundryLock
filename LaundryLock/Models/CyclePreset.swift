import Foundation

/// Dauer-Presets für typische Waschprogramme. Ein Tap auf dem Home-Screen startet die Ladung.
struct CyclePreset: Codable, Identifiable, Hashable {
    var id: Int { minutes }
    let minutes: Int
    var label: String { "\(minutes) min" }

    var duration: TimeInterval { TimeInterval(minutes * 60) }

    /// Die Standard-Presets aus der Validierung (30/45/60/90/120).
    static let defaults: [CyclePreset] = [30, 45, 60, 90, 120].map(CyclePreset.init(minutes:))

    // TODO [WEITERBAUEN]: Eigene Presets anlegen/umbenennen ("Kochwäsche", "Eco 40-60")
    // und in den Settings verwalten. Teil des einmaligen Full-Unlock (StoreKit).

    // TODO [WEITERBAUEN]: Zuletzt genutztes Preset merken und auf dem Home-Screen
    // priorisieren; später Vorschlag per App Intent / Widget in einem Tap.
}
