# Graph Report - LaundryLock  (2026-07-20)

## Corpus Check
- 32 files · ~16,920 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 260 nodes · 357 edges · 22 communities (16 shown, 6 thin omitted)
- Extraction: 95% EXTRACTED · 5% INFERRED · 0% AMBIGUOUS · INFERRED: 18 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `8e760180`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- View
- CameraService
- AppModel
- LaundrySession
- What You Must Do When Invoked
- .verify
- WEITERBAUEN — priorisierte Baustellen
- Foundation
- NotificationAlarmService
- graphify reference: extra exports and benchmark
- graphify reference: query, path, explain
- graphify reference: add a URL and watch a folder
- graphify reference: commit hook and native CLAUDE.md integration
- graphify reference: incremental update and cluster-only
- graphify reference: GitHub clone and cross-repo merge
- graphify reference: transcribe video and audio
- LaundryLockWidget — TODO [WEITERBAUEN]
- CLAUDE.md
- CLAUDE.md
- extraction-spec.md
- PersistenceStore
- AlarmVerificationView

## God Nodes (most connected - your core abstractions)
1. `LaundrySession` - 20 edges
2. `AppModel` - 19 edges
3. `WashingMachine` - 18 edges
4. `CameraService` - 18 edges
5. `View` - 14 edges
6. `What You Must Do When Invoked` - 12 edges
7. `State` - 10 edges
8. `/graphify` - 10 edges
9. `SwiftUI` - 9 edges
10. `CyclePreset` - 9 edges

## Surprising Connections (you probably didn't know these)
- `LaundryLockApp` --calls--> `AppModel`  [INFERRED]
  LaundryLock/LaundryLockApp.swift → LaundryLock/ViewModels/AppModel.swift
- `AppModel` --calls--> `NotificationAlarmService`  [INFERRED]
  LaundryLock/ViewModels/AppModel.swift → LaundryLock/Services/AlarmService.swift
- `AlarmVerificationView` --calls--> `CameraService`  [INFERRED]
  LaundryLock/Views/AlarmVerificationView.swift → LaundryLock/Services/CameraService.swift
- `MachineSetupView` --calls--> `CameraService`  [INFERRED]
  LaundryLock/Views/MachineSetupView.swift → LaundryLock/Services/CameraService.swift
- `AppModel` --calls--> `PersistenceStore`  [INFERRED]
  LaundryLock/ViewModels/AppModel.swift → LaundryLock/Services/PersistenceStore.swift

## Import Cycles
- None detected.

## Communities (22 total, 6 thin omitted)

### Community 0 - "View"
Cohesion: 0.11
Nodes (16): App, CGFloat, Theme, View, LaundryLockApp, RootView, ActiveTimerView, String (+8 more)

### Community 1 - "CameraService"
Cohesion: 0.08
Nodes (23): AnyClass, AVCapturePhoto, AVCapturePhotoCaptureDelegate, AVCapturePhotoOutput, AVCaptureSession, AVCaptureVideoPreviewLayer, AVFoundation, CheckedContinuation (+15 more)

### Community 2 - "AppModel"
Cohesion: 0.19
Nodes (11): Data, Date, String, UUID, WashingMachine, AlarmScheduling, AppModel, Bool (+3 more)

### Community 3 - "LaundrySession"
Cohesion: 0.09
Nodes (24): Codable, Hashable, Identifiable, CyclePreset, Int, String, TimeInterval, LaundrySession (+16 more)

### Community 4 - "What You Must Do When Invoked"
Cohesion: 0.08
Nodes (24): For /graphify add and --watch, For /graphify query, For the commit hook and native CLAUDE.md integration, For --update and --cluster-only, /graphify, Honesty Rules, Interpreter guard for subcommands, Part A - Structural extraction for code files (+16 more)

### Community 5 - ".verify"
Cohesion: 0.18
Nodes (12): Error, PhotoVerificationService, Result, Bool, Data, Float, UIImage, VerificationError (+4 more)

### Community 6 - "WEITERBAUEN — priorisierte Baustellen"
Cohesion: 0.12
Nodes (14): Bewusste Scaffold-Entscheidungen, 🔴 P0 — Vor allem anderen validieren (Projekt-Risiko), 🟠 P1 — Core Loop komplettieren, 🟡 P2 — Sichtbarkeit & Komfort, 🟢 P3 — Monetarisierung & Launch, WEITERBAUEN — priorisierte Baustellen, Core Loop, Design (+6 more)

### Community 7 - "Foundation"
Cohesion: 0.15
Nodes (9): Foundation, Error, Float, VerificationOutcome, failed, matched, rejected, Observation (+1 more)

### Community 8 - "NotificationAlarmService"
Cohesion: 0.21
Nodes (7): NotificationAlarmService, Bool, Int, String, TimeInterval, UUID, UserNotifications

### Community 9 - "graphify reference: extra exports and benchmark"
Cohesion: 0.22
Nodes (8): graphify reference: extra exports and benchmark, Step 6b - Wiki (only if --wiki flag), Step 7 - Neo4j export (only if --neo4j or --neo4j-push flag), Step 7a - FalkorDB export (only if --falkordb or --falkordb-push flag), Step 7b - SVG export (only if --svg flag), Step 7c - GraphML export (only if --graphml flag), Step 7d - MCP server (only if --mcp flag), Step 8 - Token reduction benchmark (only if total_words > 5000)

### Community 10 - "graphify reference: query, path, explain"
Cohesion: 0.33
Nodes (5): For /graphify explain, For /graphify path, graphify reference: query, path, explain, Step 0 — Constrained query expansion (REQUIRED before traversal), Step 1 — Traversal

### Community 11 - "graphify reference: add a URL and watch a folder"
Cohesion: 0.50
Nodes (3): For /graphify add, For --watch, graphify reference: add a URL and watch a folder

### Community 12 - "graphify reference: commit hook and native CLAUDE.md integration"
Cohesion: 0.50
Nodes (3): For git commit hook, For native CLAUDE.md integration, graphify reference: commit hook and native CLAUDE.md integration

### Community 13 - "graphify reference: incremental update and cluster-only"
Cohesion: 0.50
Nodes (3): For --cluster-only, For --update (incremental re-extraction), graphify reference: incremental update and cluster-only

### Community 20 - "PersistenceStore"
Cohesion: 0.24
Nodes (5): PersistenceStore, String, UIImage, UUID, URL

### Community 21 - "AlarmVerificationView"
Cohesion: 0.22
Nodes (8): Double, AlarmVerificationView, Feedback, error, rejected, success, Color, String

## Knowledge Gaps
- **75 isolated node(s):** `running`, `alarming`, `verified`, `overridden`, `cancelled` (+70 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **6 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AppModel` connect `AppModel` to `View`, `LaundrySession`, `Foundation`, `NotificationAlarmService`, `PersistenceStore`?**
  _High betweenness centrality (0.117) - this node is a cross-community bridge._
- **Why does `LaundrySession` connect `LaundrySession` to `NotificationAlarmService`, `View`, `AppModel`, `Foundation`?**
  _High betweenness centrality (0.108) - this node is a cross-community bridge._
- **Why does `View` connect `View` to `LaundrySession`, `AlarmVerificationView`?**
  _High betweenness centrality (0.108) - this node is a cross-community bridge._
- **Are the 3 inferred relationships involving `AppModel` (e.g. with `LaundryLockApp` and `NotificationAlarmService`) actually correct?**
  _`AppModel` has 3 INFERRED edges - model-reasoned connections that need verification._
- **Are the 3 inferred relationships involving `CameraService` (e.g. with `AVCaptureSession` and `AlarmVerificationView`) actually correct?**
  _`CameraService` has 3 INFERRED edges - model-reasoned connections that need verification._
- **What connects `running`, `alarming`, `verified` to the rest of the system?**
  _75 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `View` be split into smaller, more focused modules?**
  _Cohesion score 0.10582010582010581 - nodes in this community are weakly interconnected._