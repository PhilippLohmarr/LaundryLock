import SwiftUI

@main
struct LaundryLockApp: App {
    @State private var model = AppModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(model)
                .tint(Theme.accent) // globaler Akzent aus dem iOS-27-UI-Kit-Theme
                .onChange(of: scenePhase) { _, phase in
                    // Kommt der User zurück, während der Timer schon abgelaufen ist,
                    // direkt in den Alarm-Zustand wechseln → RootView zeigt den Foto-Flow.
                    if phase == .active { model.markAlarming() }
                }
        }
        // TODO [WEITERBAUEN]: App Intent registrieren, damit der AlarmKit-Alarm-Button
        // ("Foto machen") die App direkt in AlarmVerificationView öffnet.
        // TODO [WEITERBAUEN]: Widget/Action-Button/Siri-Start via App Intents
        // ("Starte 60-Minuten-Wäsche") — Ein-Tap-Start ist Teil des Konzepts.
    }
}

/// Routet zwischen den drei Grundzuständen der App.
struct RootView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        Group {
            if let session = model.activeSession {
                switch session.state {
                case .alarming:
                    AlarmVerificationView()
                case .running:
                    ActiveTimerView()
                default:
                    HomeView()
                }
            } else {
                HomeView()
            }
        }
        // TODO [WEITERBAUEN]: Onboarding-Flow beim ersten Start (3 Screens:
        // Problem → Lösung → Berechtigungen anfragen), danach direkt MachineSetupView.
    }
}
