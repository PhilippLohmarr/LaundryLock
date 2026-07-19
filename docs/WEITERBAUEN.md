# WEITERBAUEN — priorisierte Baustellen

Alle Punkte sind auch im Code mit `TODO [WEITERBAUEN]` markiert:

```bash
grep -rn "TODO \[WEITERBAUEN\]" LaundryLock/ LaundryLockWidget/ project.yml
```

## 🔴 P0 — Vor allem anderen validieren (Projekt-Risiko)

| # | Baustelle | Wo im Code |
|---|-----------|------------|
| 1 | **AlarmKit-Prototyp**: Kann der Alarm aktiv bleiben, während der User in den Foto-Flow geleitet wird? Lässt sich der System-Stop-Button umgehen/umbenennen? Falls nein → Nag-Loop-Strategie (Folge-Alarme bis zur Verifikation). | `Services/AlarmService.swift` |
| 2 | **Foto-Match-Threshold tunen**: Testset (Tag/Nacht/Kunstlicht, Winkel, Negativ-Beispiele) aufnehmen, Distanzen loggen, Schwellwert(e) festlegen. Startwert 0.6 ist eine Annahme. | `Services/PhotoVerificationService.swift` |

## 🟠 P1 — Core Loop komplettieren

| # | Baustelle | Wo im Code |
|---|-----------|------------|
| 3 | Durchgehender Alarmton im Verifikations-Screen (AVAudioPlayer-Loop, stoppt erst bei Match) | `AlarmService.swift`, `AlarmVerificationView.swift` |
| 4 | Echter 10s-Long-Press für den Notfall-Override (aktuell nur UI-Platzhalter) | `Views/AlarmVerificationView.swift` |
| 5 | Monatswechsel-Reset des Override-Zählers | `Services/PersistenceStore.swift` |
| 6 | App-Intent-Routing: AlarmKit-Button „Foto machen" → direkt in `AlarmVerificationView` | `LaundryLockApp.swift` |
| 7 | Snooze „+5 min" (einmalig, verschiebt endsAt + Alarm) | `Models/LaundrySession.swift`, `ActiveTimerView.swift` |
| 8 | Mehrere Referenzfotos pro Maschine (Licht/Winkel) für robusteres Matching | `Models/WashingMachine.swift` |

## 🟡 P2 — Sichtbarkeit & Komfort

| # | Baustelle | Wo im Code |
|---|-----------|------------|
| 9 | Live Activity + Widget (eigenes Target) | `LaundryLockWidget/README.md`, `project.yml` |
| 10 | Onboarding-Flow (Problem → Lösung → Berechtigungen) | `LaundryLockApp.swift` |
| 11 | Sucher-Overlay beim Setup („Maschine hier platzieren") + Qualitäts-Check des Referenzfotos | `Views/MachineSetupView.swift` |
| 12 | Erfolgs-Animation nach Match (Konfetti + Haptik) | `Views/AlarmVerificationView.swift` |
| 13 | Blitz-Handling & Tap-to-Focus für dunkle Waschkeller | `Services/CameraService.swift`, `Components/CameraPreviewView.swift` |
| 14 | Custom-Presets verwalten, zuletzt genutztes Preset priorisieren | `Models/CyclePreset.swift`, `Views/HomeView.swift` |

## 🟢 P3 — Monetarisierung & Launch

| # | Baustelle | Wo im Code |
|---|-----------|------------|
| 15 | StoreKit 2: einmaliger Kauf (4,99–7,99 €), Free-Tier-Limits (1 Maschine, 5 Alarme) | `Views/SettingsView.swift`, `ViewModels/AppModel.swift` |
| 16 | Share-Feature „X Ladungen gerettet" (viraler Hook) | `Views/HomeView.swift`, `Views/HistoryView.swift` |
| 17 | Household-Mode (Partner:in darf verifizieren) | `Models/WashingMachine.swift` |
| 18 | Nachtmodus / Rücksichts-Einstellungen für den Alarm | `Views/SettingsView.swift`, `AlarmService.swift` |
| 19 | Privacy-Texte, Support-Link, App-Store-Assets | `Views/SettingsView.swift` |

## Bewusste Scaffold-Entscheidungen

- **Foto statt QR/NFC**: Die Maschine selbst ist der Marker. Verifikation via Vision
  Feature-Print-Distanz. Nicht fälschungssicher (Foto vom Foto matcht) — das ist okay,
  Ziel ist Reibung gegen reflexhaftes Wegwischen, keine Sicherheitstechnik.
- **Notification-Fallback statt AlarmKit** ist aktuell verdrahtet (`AppModel.alarmService`),
  damit der Core Loop ohne iOS-26-Alarm-Prototyp entwickelbar ist. Umstellen, sobald P0 #1
  validiert ist.
- **JSON-Persistenz statt SwiftData**: bewusst minimal, Migration bei Bedarf.
- **Kein Backend, kein Login, kein Abo** — Konzept-Prinzip, bitte beibehalten.
