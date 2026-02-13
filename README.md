# psrziphtml
Konvertiert Windows-Schrittaufzeichnung (PSR - Problem Steps Recorder) nach HTML

# PSR to HTML Converter

Konvertiert Windows Problem Steps Recorder (PSR) `.mht` oder `.zip` Dateien in moderne, responsive HTML-Seiten mit separiertem CSS.

![Screenshot](https://img.shields.io/badge/PowerShell-5.1+-blue)
![Platform](https://img.shields.io/badge/Platform-Windows-lightgrey)

## ✨ Features

- 🖼️ **Automatische Bildextraktion** aus PSR `.mht` Dateien
- 📦 **ZIP-Support** - verarbeitet direkt heruntergeladene PSR-Archive
- 🎨 **Modernes Design** mit Blau/Grün Farbschema
- 📱 **Responsive Layout** für Desktop und Mobile
- 🔍 **Lightbox-Funktion** zum Vergrößern von Screenshots
- 📄 **Separiertes CSS** für einfache Anpassungen
- ✅ **UTF-8 Unterstützung** für Umlaute und Emojis

## 🚀 Installation

1. Repository klonen oder `Convert-to-HTML.ps1` herunterladen
2. PowerShell öffnen und zum Script-Verzeichnis navigieren
3. Falls Sicherheitswarnung erscheint: `Unblock-File .\Convert-to-HTML.ps1`

## 📖 Verwendung

### Mit ZIP-Datei (empfohlen)
```powershell
.\Convert-to-HTML.ps1 -InputFile "Recording_20260213.zip"
```

### Mit MHT-Datei
```powershell
.\Convert-to-HTML.ps1 -InputFile "Recording_20260213.mht"
```

## 📂 Output

Das Script erstellt einen Ordner mit dem Namen der Eingabedatei:

```
Recording_20260213/
├── Klickfolge.html      # Haupt-HTML-Datei
├── style.css            # Stylesheet
├── screenshot0001.JPEG
├── screenshot0002.JPEG
└── ...
```

## 🎨 Design

Das generierte HTML verwendet ein modernes Card-Design mit:
- Gradient-Hintergrund (Blau `#00058a` → Grün `#3ff245`)
- Hover-Animationen
- Nummerierte Steps mit Zeit-Anzeige
- Click-to-Zoom Screenshots
- Keyboard-Navigation (ESC zum Schließen)

## 🔧 Anpassungen

### Farben ändern

Bearbeite `style.css` nach der Generierung:

```css
/* Haupt-Gradient */
background: linear-gradient(135deg, #DEINE_FARBE1 0%, #DEINE_FARBE2 100%);

/* Step-Nummer Badge */
background: linear-gradient(135deg, #DEINE_FARBE1 0%, #DEINE_FARBE2 100%);
```

### Layout anpassen

Die CSS-Datei ist vollständig kommentiert und kann nach Bedarf angepasst werden.

## ⚙️ Technische Details

### Verarbeitung

1. **ZIP-Erkennung**: Script erkennt automatisch `.zip` Dateien
2. **Temporäres Entpacken**: ZIP wird in temp-Ordner entpackt
3. **MHT-Parsing**: Extrahiert XML-Metadaten und Base64-kodierte Bilder
4. **HTML-Generierung**: Erstellt moderne HTML-Seite mit StringBuilder
5. **Cleanup**: Entfernt temporäre Dateien automatisch

### Encoding

- Script: UTF-8 mit BOM (für korrekte Emoji/Umlaut-Darstellung)
- Output: UTF-8 ohne BOM (HTML/CSS Standard)

## 🐛 Troubleshooting

### "Ausführung von Skripts ist auf diesem System deaktiviert"
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Umlaute werden falsch dargestellt
Stelle sicher, dass das Script mit UTF-8 BOM gespeichert ist.

### Keine .mht Datei in ZIP gefunden
Prüfe ob die ZIP-Datei eine `.mht` Datei enthält (nicht nur HTML-Dateien).

## 📋 Systemanforderungen

- Windows 10/11
- PowerShell 5.1 oder höher
- .NET Framework 4.5+

## 🤝 Contributing

Contributions sind willkommen! Bitte:
1. Fork das Repository
2. Erstelle einen Feature-Branch
3. Committe deine Änderungen
4. Push zum Branch
5. Erstelle einen Pull Request

## 📝 Lizenz

MIT License - siehe LICENSE Datei für Details

## 👤 Autor

Entwickelt für die Automatisierung von PSR-Dokumentationen

## 🙏 Danksagungen

- Windows Problem Steps Recorder (PSR) für das MHT-Format
- PowerShell Community für Encoding-Tipps

---


**Hinweis**: Dieses Tool ist für Windows PSR `.mht` Dateien optimiert. Andere MHTML-Formate werden möglicherweise nicht unterstützt.

