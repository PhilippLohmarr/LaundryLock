import Foundation
import UIKit

/// Simple lokale Persistenz: eine JSON-Datei im Documents-Verzeichnis + Referenzfotos
/// als JPEGs daneben. Bewusst kein Backend, kein Login, kein Sync — Privacy ist Feature.
///
/// TODO [WEITERBAUEN]: Bei wachsendem Modell auf SwiftData migrieren (History-Queries,
/// Monats-Limit für Overrides). Für den MVP reicht die JSON-Datei völlig.
final class PersistenceStore {

    struct AppData: Codable {
        var machines: [WashingMachine] = []
        var sessions: [LaundrySession] = []
        var emergencyOverridesUsedThisMonth: Int = 0
        // TODO [WEITERBAUEN]: Monat mitspeichern und Zähler beim Monatswechsel zurücksetzen.
    }

    private let fileURL: URL
    private let photosDirectory: URL

    init() {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        fileURL = documents.appendingPathComponent("laundrylock.json")
        photosDirectory = documents.appendingPathComponent("reference-photos", isDirectory: true)
        try? FileManager.default.createDirectory(at: photosDirectory, withIntermediateDirectories: true)
    }

    func load() -> AppData {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode(AppData.self, from: data)
        else { return AppData() }
        return decoded
    }

    func save(_ appData: AppData) {
        // TODO [WEITERBAUEN]: Fehler an den User melden statt still zu schlucken
        // (voller Speicher → verlorene Maschine wäre ein Support-Fall).
        guard let data = try? JSONEncoder().encode(appData) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    // MARK: - Referenzfotos

    func saveReferencePhoto(_ image: UIImage, for machineID: UUID) throws -> String {
        let filename = "machine-\(machineID.uuidString).jpg"
        guard let data = image.jpegData(compressionQuality: 0.85) else {
            throw CocoaError(.fileWriteUnknown)
        }
        try data.write(to: photosDirectory.appendingPathComponent(filename), options: .atomic)
        return filename
    }

    func loadReferencePhoto(filename: String) -> UIImage? {
        UIImage(contentsOfFile: photosDirectory.appendingPathComponent(filename).path)
    }

    func deleteReferencePhoto(filename: String) {
        try? FileManager.default.removeItem(at: photosDirectory.appendingPathComponent(filename))
    }
}
