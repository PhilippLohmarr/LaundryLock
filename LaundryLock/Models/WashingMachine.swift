import Foundation

/// Eine registrierte Waschmaschine.
///
/// Statt QR-Code/NFC-Tag (ursprüngliches Konzept) ist die Maschine selbst der Marker:
/// Beim Einrichten wird ein Referenzfoto aufgenommen und daraus ein Vision-Feature-Print
/// berechnet. Der Alarm stoppt nur, wenn ein neues Foto nah genug am Referenz-Print liegt.
struct WashingMachine: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String

    /// Dateiname des Referenzfotos im Documents-Verzeichnis (JPEG).
    var referencePhotoFilename: String

    /// Archivierter `VNFeaturePrintObservation` des Referenzfotos
    /// (via `NSKeyedArchiver`, siehe `PhotoVerificationService`).
    var featurePrintData: Data

    var createdAt: Date

    // TODO [WEITERBAUEN]: Mehrere Referenzfotos pro Maschine erlauben (verschiedene
    // Blickwinkel / Lichtverhältnisse Tag vs. Nacht), Verifikation gegen das beste Match.
    // Ein einzelnes Foto wird bei Kellerlicht-Wechsel vermutlich zu oft fehlschlagen.

    // TODO [WEITERBAUEN]: Household-Mode — Maschine per iCloud/SharePlay mit
    // Partner:in teilen, damit jede Person den Alarm per Foto beenden kann.
}
