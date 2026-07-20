import SwiftUI

/// Design-System der App — abgeleitet aus Apples offiziellem **iOS 27 UI Kit**
/// (Apple Design Resources, Sketch-Library; Assets: apple-ios-27-ui-kit v13).
///
/// Grundsatz des Kits: Die App sieht aus wie Stock-iOS. Das heißt konkret:
///  - **Farben**: ausschließlich Systemfarben (`Color.indigo`, `.green`, `.orange`,
///    `Color(.systemGroupedBackground)` …) — nie eigene Hex-Werte. Dark Mode und
///    Kontrast-Einstellungen funktionieren damit automatisch.
///  - **Typografie**: nur SF-Pro-Textstile (`.largeTitle`, `.headline`, `.caption` …),
///    Zahlen/Countdowns in SF Rounded (`design: .rounded`) wie in Apples Timer-UI.
///  - **Material statt Deckfarbe**: Overlays auf Fotos/Kamera nutzen Liquid Glass
///    (`.glassEffect`) bzw. Materials (`.regularMaterial`), keine schwarzen Flächen.
///  - **Komponenten**: System-Buttons (`.glass` / `.glassProminent`), `List` mit
///    Inset-Grouped-Look, SF Symbols — keine nachgebauten Controls.
///  - **Radien**: große, konzentrische Eckenradien wie die Sheets/Cards im Kit.
enum Theme {

    /// App-Akzent. System-Indigo stammt aus der Systempalette des Kits
    /// (Farbreihe im Color Picker) und bleibt damit Kit-konform.
    /// TODO [WEITERBAUEN]: Als "AccentColor" ins Asset-Katalog übernehmen, damit
    /// auch Alerts, Toggles etc. systemweit den Akzent erben.
    static let accent = Color.indigo

    /// Konzentrische Eckenradien, an den Sheet-/Card-Radien des Kits orientiert
    /// (das Colors-Sheet im Kit nutzt ~28 pt, innenliegende Elemente entsprechend
    /// weniger). TODO [WEITERBAUEN]: Mit `ConcentricRectangle`/`containerConcentric`
    /// aus dem iOS-26+-SDK ersetzen, sobald am Gerät verifiziert.
    static let radiusSheet: CGFloat = 28
    static let radiusCard: CGFloat = 20
    static let radiusControl: CGFloat = 12

    /// Standard-Raster des Kits (8-pt-Grid).
    static let spacing: CGFloat = 16
    static let spacingTight: CGFloat = 8
    static let spacingSection: CGFloat = 24
}

extension View {
    /// Karten-Hintergrund im Kit-Look: Liquid Glass auf abgerundetem Rechteck.
    /// TODO [WEITERBAUEN]: `glassEffect`-API-Namen gegen das finale iOS-27-SDK
    /// prüfen (eingeführt mit iOS 26, WWDC25 "Liquid Glass").
    func glassCard() -> some View {
        self.glassEffect(.regular, in: .rect(cornerRadius: Theme.radiusCard))
    }
}
