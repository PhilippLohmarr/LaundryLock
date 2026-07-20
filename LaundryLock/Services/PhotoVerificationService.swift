import Foundation
import UIKit
import Vision

/// ⭐ Kern der App: Ersetzt den QR-/NFC-Scan des ursprünglichen Konzepts durch
/// Foto-Verifikation.
///
/// Idee: Beim Registrieren der Maschine wird ein Referenzfoto aufgenommen und daraus ein
/// `VNFeaturePrintObservation` (semantischer Bild-Fingerabdruck) berechnet. Wenn der Alarm
/// klingelt, muss der User ein neues Foto der Maschine machen. Liegt die Feature-Print-Distanz
/// unter dem Schwellwert, gilt: "User steht vor der Maschine" → Alarm aus.
///
/// Ziel ist NICHT fälschungssichere Verifikation (ein Foto vom Referenzfoto würde matchen),
/// sondern genug bewusste Reibung, um reflexhaftes Wegwischen zu unterbrechen.
enum PhotoVerificationService {

    enum VerificationError: Error {
        case noFeaturePrint
        case invalidReferenceData
    }

    struct Result {
        let isMatch: Bool
        let distance: Float
        let threshold: Float
    }

    /// Maximale Feature-Print-Distanz, bei der zwei Fotos als "gleiche Maschine" gelten.
    ///
    /// TODO [WEITERBAUEN]: Schwellwert empirisch tunen! Das ist die wichtigste offene
    /// Baustelle. Vorgehen:
    ///   1. Testset aufnehmen: gleiche Maschine bei Tag/Nacht/Kunstlicht, verschiedene
    ///      Winkel & Abstände, plus Negativ-Beispiele (andere Maschinen, Kühlschrank, Sofa).
    ///   2. Distanzen loggen (siehe Debug-Log unten) und ROC-artige Auswertung machen.
    ///   3. Ggf. zwei Schwellwerte: sicherer Match / "fast" (→ zweiten Versuch anbieten
    ///      statt hart abzulehnen, sonst frustriert die App im Keller bei schlechtem Licht).
    /// Der Startwert 0.6 ist eine grobe Annahme für VNGenerateImageFeaturePrintRequest
    /// Revision 2 und muss auf echten Geräten validiert werden.
    static let matchThreshold: Float = 0.6

    // MARK: - Feature-Print berechnen

    static func featurePrint(for image: UIImage) throws -> VNFeaturePrintObservation {
        guard let cgImage = image.cgImage else { throw VerificationError.noFeaturePrint }
        let request = VNGenerateImageFeaturePrintRequest()
        // TODO [WEITERBAUEN]: request.revision explizit pinnen, damit gespeicherte
        // Referenz-Prints nach einem iOS-Update kompatibel bleiben. Bei Revisions-Wechsel
        // Migration: Referenzfoto neu durch die aktuelle Revision jagen.
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up)
        try handler.perform([request])
        guard let observation = request.results?.first as? VNFeaturePrintObservation else {
            throw VerificationError.noFeaturePrint
        }
        return observation
    }

    /// Serialisiert einen Feature-Print für die Persistenz in `WashingMachine`.
    static func archive(_ observation: VNFeaturePrintObservation) throws -> Data {
        try NSKeyedArchiver.archivedData(withRootObject: observation, requiringSecureCoding: true)
    }

    static func unarchive(_ data: Data) throws -> VNFeaturePrintObservation {
        guard let observation = try NSKeyedUnarchiver.unarchivedObject(
            ofClass: VNFeaturePrintObservation.self, from: data
        ) else { throw VerificationError.invalidReferenceData }
        return observation
    }

    // MARK: - Verifikation

    /// Vergleicht ein frisch aufgenommenes Alarm-Foto mit dem Referenz-Print der Maschine.
    static func verify(candidate: UIImage, against machine: WashingMachine) throws -> Result {
        let reference = try unarchive(machine.featurePrintData)
        let candidatePrint = try featurePrint(for: candidate)

        var distance: Float = .greatestFiniteMagnitude
        try candidatePrint.computeDistance(&distance, to: reference)

        // TODO [WEITERBAUEN]: Distanz + Ergebnis lokal loggen (für Threshold-Tuning,
        // niemals Fotos hochladen — Privacy-Versprechen: alles bleibt auf dem Gerät).
        #if DEBUG
        print("[PhotoVerification] distance=\(distance) threshold=\(matchThreshold)")
        #endif

        return Result(
            isMatch: distance <= matchThreshold,
            distance: distance,
            threshold: matchThreshold
        )
    }

    // TODO [WEITERBAUEN]: Robustheit erhöhen —
    //  a) Zusätzlich VNClassifyImageRequest nutzen und prüfen, ob überhaupt ein Objekt
    //     "washing machine / appliance" im Bild erkannt wird (verhindert Match auf ein
    //     Foto der leeren Kellerwand, wenn das Referenzfoto auch nur Wand zeigt).
    //  b) Alternativ ein kleines On-Device-CoreML-Embedding-Modell evaluieren, falls die
    //     Feature-Print-Distanzen bei Lichtwechsel zu stark streuen.
    //  c) Live-Erkennung im Kamera-Stream (statt Foto schießen): Sucher zeigt grünen
    //     Rahmen sobald die Maschine erkannt wird → noch weniger Frust, tolles Demo-Video.
}
