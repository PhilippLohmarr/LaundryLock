import Foundation
import UserNotifications

/// Plant und stoppt den "unüberhörbaren" Alarm am Ende des Waschgangs.
///
/// ⚠️ GRÖSSTES TECHNISCHES RISIKO DES PROJEKTS (vor UI-Politur validieren!):
/// AlarmKit (iOS 26) kann prominente Alarme auf Lock Screen / Dynamic Island zeigen, die
/// Stumm & Fokus durchbrechen. Unklar ist, ob sich der System-Stop-Button so gestalten
/// lässt, dass der User zwingend in den Foto-Flow geleitet wird. Falls das System immer
/// einen bedingungslosen Stop anbietet, ist die Fallback-Strategie: Alarm stoppt zwar,
/// aber die App plant sofort Folge-Alarme im Minutentakt ("Nag-Loop"), bis die
/// Foto-Verifikation erfolgt ist — transparente "Honor-System-Reibung" statt harter Sperre.
protocol AlarmScheduling {
    func requestAuthorization() async -> Bool
    /// Plant den Alarm für das Ende der Session.
    func scheduleAlarm(for session: LaundrySession) async throws
    /// Beendet Alarm + alle Folge-Alarme (nach erfolgreicher Verifikation oder Override).
    func cancelAlarm(for sessionID: UUID) async
}

// MARK: - AlarmKit (iOS 26) — der eigentliche Zielpfad

// TODO [WEITERBAUEN]: AlarmKit-Implementierung — DIES ZUERST PROTOTYPEN.
// Skizze (API-Namen gegen das finale iOS-26-SDK prüfen, Quelle: WWDC25 Session 230
// "Wake up to the AlarmKit API"):
//
//   import AlarmKit
//
//   final class AlarmKitService: AlarmScheduling {
//       func requestAuthorization() async -> Bool {
//           // AlarmManager.shared.requestAuthorization()
//       }
//       func scheduleAlarm(for session: LaundrySession) async throws {
//           // 1. AlarmPresentation.Alert mit Titel "Wäsche ist fertig! 🧺"
//           // 2. secondaryButton "Foto machen" mit Behavior .custom
//           //    → öffnet die App via App Intent direkt in AlarmVerificationView
//           // 3. AlarmManager.shared.schedule(id: session.id, configuration: ...)
//           //    mit countdownDuration bis session.endsAt
//       }
//       func cancelAlarm(for sessionID: UUID) async {
//           // AlarmManager.shared.stop(id:) / .cancel(id:)
//       }
//   }
//
// Zu klären beim Prototyping:
//  - Lässt sich der Stop-Button unterdrücken oder nur umbenennen?
//  - Bleibt der Alarm aktiv, während die App im Vordergrund den Kamera-Flow zeigt?
//  - Verhalten auf Apple Watch (Alarm spiegeln, aber Verifikation nur am iPhone).

// MARK: - Notification-Fallback (funktioniert ab iOS 17, gut für frühe Tests)

/// Fallback über UNUserNotificationCenter: eine Kette von zeitversetzten, penetranten
/// Local Notifications ("Nag-Loop"). Kein echter Alarm-Durchbruch bei Stumm/Fokus,
/// aber ausreichend, um den Core Loop und die Foto-Verifikation zu entwickeln.
final class NotificationAlarmService: AlarmScheduling {

    /// Anzahl + Abstand der Folge-Erinnerungen nach dem Haupt-Alarm.
    /// TODO [WEITERBAUEN]: In den Settings konfigurierbar machen (Nacht-Rücksicht:
    /// "Nach 22 Uhr nur 3 Wiederholungen" — Risiko aus der Validierung: Alarm nervt
    /// den Haushalt mehr als die vergessene Wäsche).
    private let nagCount = 10
    private let nagInterval: TimeInterval = 60

    func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        // TODO [WEITERBAUEN]: .criticalAlert erfordert ein Apple-Entitlement, das für
        // diesen Use Case vermutlich nicht bewilligt wird → mit AlarmKit obsolet.
        return (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    func scheduleAlarm(for session: LaundrySession) async throws {
        let center = UNUserNotificationCenter.current()

        for nag in 0...nagCount {
            let content = UNMutableNotificationContent()
            content.title = nag == 0 ? "Wäsche ist fertig! 🧺" : "Die Wäsche wartet immer noch…"
            content.body = "Geh zur Waschmaschine und mach ein Foto, um den Alarm zu stoppen."
            content.sound = .defaultCritical
            content.interruptionLevel = .timeSensitive
            content.userInfo = ["sessionID": session.id.uuidString]

            let fireIn = max(1, session.endsAt.timeIntervalSinceNow + Double(nag) * nagInterval)
            let request = UNNotificationRequest(
                identifier: Self.identifier(for: session.id, nag: nag),
                content: content,
                trigger: UNTimeIntervalNotificationTrigger(timeInterval: fireIn, repeats: false)
            )
            try await center.add(request)
        }
    }

    func cancelAlarm(for sessionID: UUID) async {
        let ids = (0...nagCount).map { Self.identifier(for: sessionID, nag: $0) }
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ids)
        center.removeDeliveredNotifications(withIdentifiers: ids)
    }

    private static func identifier(for sessionID: UUID, nag: Int) -> String {
        "laundry-alarm-\(sessionID.uuidString)-\(nag)"
    }
}

// TODO [WEITERBAUEN]: Kontinuierlicher Alarmton, solange AlarmVerificationView offen ist
// (AVAudioPlayer in Loop, Kategorie .playback), damit der Ton erst mit erfolgreichem
// Foto-Match verstummt — die Notification allein trägt den Ton nicht durch den Kamera-Flow.
