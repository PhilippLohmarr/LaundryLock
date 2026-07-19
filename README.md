# LaundryLock 🧺🔒

Ein extrem fokussiertes iOS-Utility: Wenn der Waschgang endet, klingelt ein prominenter
Alarm so lange, bis du **zur Waschmaschine gehst und ein Foto von ihr machst**.

Statt QR-Code oder NFC-Tag (wie im ursprünglichen Konzept) nutzt LaundryLock
**Foto-Verifikation**: Beim Einrichten wird ein Referenzfoto der Maschine aufgenommen.
Der Alarm stoppt erst, wenn ein neu aufgenommenes Foto per Vision-Framework
(Feature-Print-Vergleich) als „dieselbe Maschine" erkannt wird. Kein Sticker, kein Tag —
die Maschine selbst ist der Marker.

## Core Loop

```
Waschgang starten → Countdown läuft → unüberhörbarer Alarm (AlarmKit)
→ zur Maschine laufen → Foto machen → Vision vergleicht mit Referenzfoto
→ Match? → Alarm aus → Wäsche umräumen ✅
```

## Projekt-Struktur

```
LaundryLock/
├── project.yml                  # XcodeGen-Definition (auf dem Mac: `xcodegen generate`)
├── LaundryLock/                 # App-Sources (SwiftUI, iOS 26+)
│   ├── LaundryLockApp.swift     # App-Entry, Routing zum Alarm-Screen
│   ├── Models/                  # WashingMachine, CyclePreset, LaundrySession
│   ├── Services/
│   │   ├── PhotoVerificationService.swift  # ⭐ Kern: Vision Feature-Print-Vergleich
│   │   ├── AlarmService.swift              # AlarmKit (iOS 26) + Notification-Fallback
│   │   ├── CameraService.swift             # AVFoundation-Kamera für Setup & Alarm
│   │   └── PersistenceStore.swift          # Lokale JSON-Persistenz (kein Backend!)
│   ├── ViewModels/
│   │   └── AppModel.swift       # Zentraler @Observable App-State
│   └── Views/
│       ├── HomeView.swift               # Dauer-Presets + aktive Ladung
│       ├── MachineSetupView.swift       # Referenzfoto aufnehmen
│       ├── ActiveTimerView.swift        # Countdown
│       ├── AlarmVerificationView.swift  # ⭐ Vollbild-Kamera: „Geh zur Waschmaschine"
│       ├── HistoryView.swift            # Gerettete Ladungen
│       └── SettingsView.swift           # Presets, Sound, Overrides
├── LaundryLockWidget/           # TODO: Live Activity + Widget (eigenes Target)
└── docs/WEITERBAUEN.md          # 📌 Alle offenen Baustellen auf einen Blick
```

## Setup auf dem Mac

1. [XcodeGen](https://github.com/yonaskolb/XcodeGen) installieren: `brew install xcodegen`
2. Im Repo-Root: `xcodegen generate`
3. `LaundryLock.xcodeproj` öffnen, Signing-Team setzen, auf einem **echten Gerät** laufen
   lassen (Kamera + AlarmKit funktionieren im Simulator nur eingeschränkt).

Minimum Deployment Target: **iOS 26** (wegen AlarmKit). Der Notification-Fallback in
`AlarmService.swift` erlaubt Tests auf älteren Geräten.

## Wo weiterbauen?

Alle offenen Punkte sind im Code mit `TODO [WEITERBAUEN]` markiert — durchsuchbar mit:

```bash
grep -rn "TODO \[WEITERBAUEN\]" LaundryLock/
```

Die priorisierte Gesamtliste steht in [`docs/WEITERBAUEN.md`](docs/WEITERBAUEN.md).

## Graphify (Knowledge Graph)

Das Repo hat [Graphify](https://github.com/Graphify-Labs/graphify) installiert
(`.claude/skills/graphify/` + Hooks in `.claude/settings.json`). Der Code-Graph liegt in
`graphify-out/` (`graph.html` im Browser öffnen, `GRAPH_REPORT.md` lesen, `graph.json`
für Queries).

**Einmalig auf deinem Mac** (die Hook-Pfade in `.claude/settings.json` zeigen sonst auf
den Cloud-Container, in dem installiert wurde):

```bash
uv tool install graphifyy
graphify install --project   # schreibt die Hook-Pfade für dein System neu
```

Danach: `/graphify .` in Claude Code, oder `graphify update .` nach Code-Änderungen
(rein lokal via tree-sitter, kein LLM nötig) und `graphify query "<Frage>"` für Abfragen.

## Prinzipien (aus der Validierung)

- **Kein Backend, kein Login, kein Abo.** Alles lokal, einmaliger Kauf später via StoreKit.
- **Reibung ist Absicht** — aber ehrlich: Es gibt einen bewussten Notfall-Override
  (10-Sekunden-Hold, limitiert pro Monat). Die App behauptet nicht, Cheaten unmöglich
  zu machen; sie unterbricht das reflexhafte Wegwischen.
- **Größtes technisches Risiko zuerst validieren:** Kann AlarmKit den Alarm aktiv halten,
  während der User in den Kamera-Flow geleitet wird? → siehe `AlarmService.swift`.
