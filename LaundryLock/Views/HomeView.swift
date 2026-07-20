import SwiftUI

/// MVP-Screen 1: Große Dauer-Presets + Zugang zu Setup, History und Settings.
struct HomeView: View {
    @Environment(AppModel.self) private var model
    @State private var showMachineSetup = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if let machine = model.primaryMachine {
                        machineHeader(machine)
                        presetGrid(machine: machine)
                    } else {
                        setupPrompt
                    }

                    if model.rescuedLoadsCount > 0 {
                        // Shareable-Metrik aus dem Konzept: "X Ladungen gerettet"
                        Label("\(model.rescuedLoadsCount) Ladungen gerettet", systemImage: "trophy.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.orange)
                        // TODO [WEITERBAUEN]: Teilen-Button (ShareLink) mit hübscher
                        // Wochen-Grafik — der virale Hook aus der Distribution-Strategie.
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("LaundryLock")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink { HistoryView() } label: { Image(systemName: "clock.arrow.circlepath") }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink { SettingsView() } label: { Image(systemName: "gearshape") }
                }
            }
            .sheet(isPresented: $showMachineSetup) { MachineSetupView() }
        }
    }

    // MARK: - Subviews

    // Card im Inset-Grouped-Look des Kits (Systemfarben, konzentrische Radien).
    private func machineHeader(_ machine: WashingMachine) -> some View {
        HStack(spacing: Theme.spacing) {
            if let photo = model.referencePhoto(for: machine) {
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.radiusControl))
            }
            VStack(alignment: .leading) {
                Text(machine.name).font(.headline)
                Text("Registriert per Referenzfoto").font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(Theme.spacing)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: Theme.radiusCard))
    }

    private func presetGrid(machine: WashingMachine) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
            ForEach(CyclePreset.defaults) { preset in
                Button {
                    Task { await model.startLoad(machine: machine, preset: preset) }
                } label: {
                    VStack {
                        // SF Rounded für Zahlen, wie Apples Timer/Clock-UI im Kit
                        Text("\(preset.minutes)").font(.system(.largeTitle, design: .rounded, weight: .bold))
                        Text("Minuten").font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                }
                // Liquid-Glass-Button (iOS 26+), erbt den globalen Akzent
                .buttonStyle(.glassProminent)
            }
        }
        // TODO [WEITERBAUEN]: Eigene Dauer per Stepper/Wheel ("Custom") ergänzen.
    }

    private var setupPrompt: some View {
        VStack(spacing: 16) {
            Image(systemName: "washer")
                .font(.system(size: 64))
                .foregroundStyle(.tint)
            Text("Registriere zuerst deine Waschmaschine")
                .font(.title3.weight(.semibold))
                .multilineTextAlignment(.center)
            Text("Mach ein Foto deiner Maschine — es wird später gebraucht, um den Alarm zu stoppen.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Foto aufnehmen") { showMachineSetup = true }
                .buttonStyle(.glassProminent)
        }
        .padding(.top, 60)
    }
}

#Preview {
    HomeView().environment(AppModel())
}
