import SwiftUI

/// ⭐ MVP-Screen 4: Vollbild-Kamera im Alarm-Zustand.
/// Der Alarm endet erst, wenn ein Foto der registrierten Maschine gemacht wurde
/// (Foto-Verifikation statt QR-Scan). Notausgang: 10-Sekunden-Hold, limitiert pro Monat.
struct AlarmVerificationView: View {
    @Environment(AppModel.self) private var model
    @StateObject private var camera = CameraService()

    @State private var isVerifying = false
    @State private var feedback: Feedback?
    @State private var overrideProgress: Double = 0

    enum Feedback { case success, rejected, error }

    var body: some View {
        ZStack {
            CameraPreviewView(session: camera.session)
                .ignoresSafeArea()

            VStack {
                header
                Spacer()
                feedbackBanner
                captureButton
                overrideButton
            }
            .padding()
        }
        .task {
            await camera.requestAccess()
            try? await camera.configureAndStart()
            // TODO [WEITERBAUEN]: Hier den durchgehenden Alarmton starten (AVAudioPlayer,
            // Loop) und erst bei .success stoppen — siehe Notiz in AlarmService.swift.
        }
        .onDisappear { camera.stopRunning() }
    }

    // MARK: - Subviews

    private var header: some View {
        VStack(spacing: 8) {
            Text("🧺 Wäsche ist fertig!")
                .font(.largeTitle.bold())
            Text("Geh zur Waschmaschine und fotografiere sie, um den Alarm zu stoppen.")
                .font(.headline)
                .multilineTextAlignment(.center)
        }
        .foregroundStyle(.white)
        .padding()
        .background(.black.opacity(0.55), in: RoundedRectangle(cornerRadius: 16))
    }

    @ViewBuilder
    private var feedbackBanner: some View {
        switch feedback {
        case .success:
            banner("✅ Das ist sie! Alarm beendet — Wäsche umräumen!", color: .green)
        case .rejected:
            banner("❌ Das sieht nicht nach deiner Maschine aus. Geh näher ran und versuch es nochmal.", color: .red)
            // TODO [WEITERBAUEN]: Bei knappem Miss (Distanz nahe am Threshold) mildere
            // Meldung + Tipp ("mehr Licht / frontal fotografieren") statt hartem Nein.
        case .error:
            banner("⚠️ Foto konnte nicht geprüft werden. Nochmal versuchen.", color: .orange)
        case nil:
            EmptyView()
        }
    }

    private func banner(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.callout.weight(.semibold))
            .foregroundStyle(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(color.opacity(0.85), in: RoundedRectangle(cornerRadius: 12))
    }

    private var captureButton: some View {
        Button {
            Task { await captureAndVerify() }
        } label: {
            Label("Foto machen", systemImage: "camera.fill")
                .font(.title3.weight(.bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
        }
        .buttonStyle(.borderedProminent)
        .tint(.indigo)
        .disabled(isVerifying || feedback == .success)
    }

    /// Notfall-Override: nur nach bewusstem 10-Sekunden-Hold, limitiert pro Monat.
    private var overrideButton: some View {
        VStack(spacing: 4) {
            Text("Notfall: 10 Sekunden gedrückt halten (\(model.emergencyOverridesPerMonth - model.emergencyOverridesUsedThisMonth) übrig diesen Monat)")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.7))
            ProgressView(value: overrideProgress)
                .tint(.red)
                .opacity(overrideProgress > 0 ? 1 : 0)
        }
        .padding(.top, 8)
        // TODO [WEITERBAUEN]: Echten 10s-Long-Press implementieren
        // (.onLongPressGesture(minimumDuration: 10) mit Fortschrittsanzeige über
        // onPressingChanged) und dann model.useEmergencyOverride() aufrufen.
        // Aktuell nur UI-Platzhalter.
    }

    // MARK: - Verifikation

    private func captureAndVerify() async {
        isVerifying = true
        defer { isVerifying = false }
        feedback = nil

        guard let photo = try? await camera.capturePhoto() else {
            feedback = .error
            return
        }

        switch await model.verifyAlarmPhoto(photo) {
        case .matched:
            feedback = .success
            // RootView routet automatisch zurück zur HomeView, weil die Session
            // nicht mehr aktiv ist. Kurze Erfolgs-Anzeige wäre schöner:
            // TODO [WEITERBAUEN]: Erfolgs-Animation (Konfetti + Haptik) für 1–2 s
            // zeigen, bevor zurück zur HomeView geroutet wird.
        case .rejected:
            feedback = .rejected
        case .failed:
            feedback = .error
        }
    }
}

#Preview {
    AlarmVerificationView().environment(AppModel())
}
