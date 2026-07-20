# LaundryLockWidget — TODO [WEITERBAUEN]

Eigenes Widget-Extension-Target für:

1. **Live Activity**: Countdown des laufenden Waschgangs auf Lock Screen, Dynamic Island
   und StandBy. Kern-Feature aus dem Konzept — die Restzeit soll sichtbar bleiben, ohne
   die App zu öffnen.
2. **Home-/Lock-Screen-Widget**: Ein-Tap-Start der häufigsten Presets via App Intents.

## Schritte

1. In `project.yml` das auskommentierte `LaundryLockWidget`-Target aktivieren
   (`type: app-extension`) und `NSSupportsLiveActivities: true` in der App-Info setzen.
2. `ActivityAttributes` definieren (machineName, endsAt) — geteilt zwischen App und
   Widget über eine gemeinsame Source-Gruppe.
3. In `AppModel.startLoad` die Live Activity starten, in `verifyAlarmPhoto` /
   `cancelActiveLoad` beenden.
4. `StartWashIntent` (App Intent) für Widget-Buttons, Action Button und Siri:
   „Starte 60-Minuten-Wäsche".
