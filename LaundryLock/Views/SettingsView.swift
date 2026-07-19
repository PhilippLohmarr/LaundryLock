import SwiftUI

/// MVP-Screen 5b: Einstellungen — Maschine verwalten, Sound, Overrides, Kauf.
struct SettingsView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        List {
            Section("Waschmaschinen") {
                ForEach(model.machines) { machine in
                    HStack {
                        if let photo = model.referencePhoto(for: machine) {
                            Image(uiImage: photo)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        Text(machine.name)
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet { model.deleteMachine(model.machines[index]) }
                }
                // TODO [WEITERBAUEN]: "Referenzfoto erneuern"-Aktion (Maschine umgezogen,
                // Licht dauerhaft anders) — MachineSetupView im Edit-Modus öffnen.
            }

            Section("Alarm") {
                LabeledContent("Notfall-Overrides", value: "\(model.emergencyOverridesUsedThisMonth)/\(model.emergencyOverridesPerMonth) benutzt")
                // TODO [WEITERBAUEN]: Alarmton-Auswahl + Lautstärke-Vorschau.
                // TODO [WEITERBAUEN]: Nachtmodus (weniger Nag-Wiederholungen nach 22 Uhr).
            }

            Section("LaundryLock Vollversion") {
                // TODO [WEITERBAUEN]: StoreKit-2-Integration — einmaliger Kauf 4,99–7,99 €:
                // unbegrenzte Presets, mehrere Maschinen, Widgets, Watch-Start, Household.
                // Free-Tier: 1 Maschine, 60-min-Preset, 5 abgeschlossene Alarme.
                Text("Einmalig kaufen — kein Abo")
                    .foregroundStyle(.secondary)
            }

            Section {
                // TODO [WEITERBAUEN]: Privacy-Text verlinken ("Alle Fotos bleiben auf
                // deinem Gerät") + Support-Kontakt — Pflicht für App-Store-Review.
                Text("Alle Fotos und Daten bleiben ausschließlich auf deinem Gerät.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Einstellungen")
    }
}

#Preview {
    NavigationStack { SettingsView() }.environment(AppModel())
}
