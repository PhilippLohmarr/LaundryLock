import SwiftUI

/// MVP-Screen 2: Waschmaschine per Referenzfoto registrieren (ersetzt QR/NFC-Setup).
struct MachineSetupView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @StateObject private var camera = CameraService()

    @State private var machineName = ""
    @State private var capturedPhoto: UIImage?
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                if let photo = capturedPhoto {
                    reviewSection(photo)
                } else {
                    captureSection
                }
            }
            .padding()
            .navigationTitle("Maschine registrieren")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
            }
            .task {
                await camera.requestAccess()
                try? await camera.configureAndStart()
            }
            .onDisappear { camera.stopRunning() }
            .alert("Fehler", isPresented: .constant(errorMessage != nil)) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    // MARK: - Schritt 1: Foto aufnehmen

    private var captureSection: some View {
        VStack(spacing: 16) {
            Text("Stell dich vor die Maschine und fotografiere sie frontal — so wie du sie auch später beim Alarm fotografieren wirst.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            CameraPreviewView(session: camera.session)
                .aspectRatio(3 / 4, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            // TODO [WEITERBAUEN]: Overlay-Rahmen im Sucher ("Maschine hier platzieren"),
            // damit Referenz- und Alarm-Foto ähnlich gerahmt werden → bessere Match-Rate.

            Button {
                Task {
                    capturedPhoto = try? await camera.capturePhoto()
                    if capturedPhoto == nil { errorMessage = camera.captureError }
                }
            } label: {
                Label("Referenzfoto aufnehmen", systemImage: "camera.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.indigo)
            .disabled(!camera.isAuthorized)
        }
    }

    // MARK: - Schritt 2: Prüfen & speichern

    private func reviewSection(_ photo: UIImage) -> some View {
        VStack(spacing: 16) {
            Image(uiImage: photo)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 16))

            TextField("Name (z. B. „Keller“ oder „Bad“)", text: $machineName)
                .textFieldStyle(.roundedBorder)

            HStack {
                Button("Neu aufnehmen") { capturedPhoto = nil }
                    .buttonStyle(.bordered)
                Button("Speichern") {
                    do {
                        try model.registerMachine(name: machineName, referencePhoto: photo)
                        dismiss()
                    } catch {
                        errorMessage = "Konnte kein Bild-Profil berechnen. Versuch es mit mehr Licht erneut."
                        // TODO [WEITERBAUEN]: Qualitäts-Check direkt nach der Aufnahme
                        // (zu dunkel? verwackelt?) statt erst beim Speichern zu scheitern.
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.indigo)
            }
        }
    }
}

#Preview {
    MachineSetupView().environment(AppModel())
}
