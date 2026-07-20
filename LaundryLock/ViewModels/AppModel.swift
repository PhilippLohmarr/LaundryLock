import Foundation
import Observation
import UIKit

/// Zentraler App-State: Maschinen, aktive Ladung, History.
/// Wird als Environment-Objekt durch die gesamte View-Hierarchie gereicht.
@MainActor
@Observable
final class AppModel {

    // MARK: - State

    private(set) var machines: [WashingMachine] = []
    private(set) var sessions: [LaundrySession] = []
    private(set) var emergencyOverridesUsedThisMonth = 0

    /// Wie viele Notfall-Overrides pro Monat erlaubt sind (bewusste, transparente Reibung).
    let emergencyOverridesPerMonth = 3

    var activeSession: LaundrySession? { sessions.first(where: \.isActive) }
    var primaryMachine: WashingMachine? { machines.first }
    var rescuedLoadsCount: Int {
        sessions.filter { if case .verified = $0.state { return true } else { return false } }.count
    }

    // MARK: - Dependencies

    private let store = PersistenceStore()
    /// TODO [WEITERBAUEN]: Auf `AlarmKitService` umstellen, sobald prototypisch validiert
    /// (siehe AlarmService.swift). Der Notification-Fallback dient nur der Entwicklung.
    private let alarmService: AlarmScheduling = NotificationAlarmService()

    init() {
        let data = store.load()
        machines = data.machines
        sessions = data.sessions
        emergencyOverridesUsedThisMonth = data.emergencyOverridesUsedThisMonth
    }

    // MARK: - Maschine registrieren (Setup-Flow)

    /// Registriert eine Maschine mit dem aufgenommenen Referenzfoto.
    func registerMachine(name: String, referencePhoto: UIImage) throws {
        let id = UUID()
        let featurePrint = try PhotoVerificationService.featurePrint(for: referencePhoto)
        let printData = try PhotoVerificationService.archive(featurePrint)
        let filename = try store.saveReferencePhoto(referencePhoto, for: id)

        let machine = WashingMachine(
            id: id,
            name: name.isEmpty ? "Waschmaschine" : name,
            referencePhotoFilename: filename,
            featurePrintData: printData,
            createdAt: Date()
        )
        machines.append(machine)
        persist()
        // TODO [WEITERBAUEN]: Free-Tier-Limit — 1 Maschine gratis, weitere nur mit
        // Full Unlock (StoreKit-One-Time-Purchase, 4,99–7,99 €).
    }

    func deleteMachine(_ machine: WashingMachine) {
        store.deleteReferencePhoto(filename: machine.referencePhotoFilename)
        machines.removeAll { $0.id == machine.id }
        persist()
    }

    func referencePhoto(for machine: WashingMachine) -> UIImage? {
        store.loadReferencePhoto(filename: machine.referencePhotoFilename)
    }

    // MARK: - Wasch-Ladung starten / beenden (Core Loop)

    func startLoad(machine: WashingMachine, preset: CyclePreset) async {
        guard activeSession == nil else { return } // MVP: eine Ladung gleichzeitig

        let session = LaundrySession.start(machineID: machine.id, preset: preset)
        sessions.insert(session, at: 0)
        persist()

        _ = await alarmService.requestAuthorization()
        try? await alarmService.scheduleAlarm(for: session)

        // TODO [WEITERBAUEN]: Live Activity starten (Countdown auf Lock Screen /
        // Dynamic Island) — braucht das Widget-Target, siehe LaundryLockWidget/README.md.
    }

    func cancelActiveLoad() async {
        guard var session = activeSession else { return }
        session.state = .cancelled(at: Date())
        update(session)
        await alarmService.cancelAlarm(for: session.id)
    }

    /// Wird aufgerufen, wenn der Countdown abgelaufen ist (App aktiv) oder der User
    /// über die Alarm-Notification in die App kommt.
    func markAlarming() {
        guard var session = activeSession, case .running = session.state,
              session.remaining <= 0 else { return }
        session.state = .alarming
        update(session)
    }

    // MARK: - Foto-Verifikation (ersetzt den QR-Scan)

    enum VerificationOutcome {
        case matched            // Alarm aus, Ladung gerettet 🎉
        case rejected(distance: Float)  // Foto zeigt nicht die registrierte Maschine
        case failed(Error)
    }

    func verifyAlarmPhoto(_ photo: UIImage) async -> VerificationOutcome {
        guard var session = activeSession,
              let machine = machines.first(where: { $0.id == session.machineID })
        else { return .failed(PhotoVerificationService.VerificationError.invalidReferenceData) }

        do {
            let result = try PhotoVerificationService.verify(candidate: photo, against: machine)
            guard result.isMatch else { return .rejected(distance: result.distance) }

            session.state = .verified(at: Date())
            update(session)
            await alarmService.cancelAlarm(for: session.id)
            return .matched
        } catch {
            return .failed(error)
        }
    }

    /// Notfall-Override: 10-Sekunden-Hold in der UI, limitiert pro Monat.
    func useEmergencyOverride() async -> Bool {
        guard emergencyOverridesUsedThisMonth < emergencyOverridesPerMonth,
              var session = activeSession else { return false }
        emergencyOverridesUsedThisMonth += 1
        session.state = .overridden(at: Date())
        update(session)
        await alarmService.cancelAlarm(for: session.id)
        return true
    }

    // MARK: - Helpers

    private func update(_ session: LaundrySession) {
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index] = session
        }
        persist()
    }

    private func persist() {
        store.save(.init(
            machines: machines,
            sessions: sessions,
            emergencyOverridesUsedThisMonth: emergencyOverridesUsedThisMonth
        ))
    }

    // TODO [WEITERBAUEN]: App-Lifecycle sauber behandeln — wenn die App im Hintergrund
    // war und endsAt inzwischen überschritten ist, beim Foreground-Wechsel direkt in den
    // Alarm-/Verifikations-Screen springen (scenePhase in LaundryLockApp.swift).
}
