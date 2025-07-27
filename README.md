# Mainprompt Manager v2.0 - Multilingual

Ein mehrsprachiges Shell-Tool zum Verwalten und Wechseln zwischen verschiedenen System-Prompts für Claude AI.

## 🚀 Features

- **Mehrsprachige Unterstützung**: Vollständig auf Deutsch und Englisch verfügbar
- **Main Prompt Management**: Klare Unterscheidung zwischen Main Prompts und Platform Prompts
- **Platform Prompt Templates**: Vordefinierte Templates in beiden Sprachen
- **Einfacher Prompt-Wechsel**: Wählt aus allen Templates im Template-Verzeichnis
- **Neue Prompts erstellen**: Interaktive Erstellung mit nano
- **Config-Verwaltung**: Konfigurierbare Pfade und Einstellungen
- **Private Templates**: Separate Verwaltung privater Prompts pro Sprache
- **YAML-Header Support**: Zeigt Namen und Projekt-Informationen
- **Farbige Ausgabe**: Übersichtliche Darstellung mit Farb-Highlighting
- **Cross-Platform**: Funktioniert auf Linux, Mac und Windows

## 📋 Voraussetzungen

- Bash Shell
- Linux/Unix System (getestet auf Ubuntu/Debian)
- jq (JSON-Prozessor) - für Config-Verwaltung
- Schreibrechte im Systemprompts-Verzeichnis

## 🛠️ Installation

1. Repository klonen:
```bash
git clone https://github.com/IhrUsername/mainprompt-manager.git
cd mainprompt-manager
```

2. Ausführbar machen (falls nicht bereits geschehen):
```bash
chmod +x prompt-manager.sh
```

3. Optional: Symbolischen Link erstellen für systemweiten Zugriff:
```bash
sudo ln -s $(pwd)/prompt-manager.sh /usr/local/bin/prompt-manager
```

## 📖 Verwendung

### Grundlegende Verwendung

```bash
./prompt-manager.sh
```

Das Tool zeigt ein Hauptmenü mit folgenden Optionen:
1. **Prompt wechseln**: Zeigt alle verfügbaren Prompts zur Auswahl
2. **Neuen Prompt erstellen**: Interaktive Erstellung eines neuen Prompts
3. **Config bearbeiten**: Pfade und Einstellungen anpassen
4. **Plattform-Prompt erstellen**: Generiert einen Plattform-spezifischen Prompt
5. **Plattform-Prompt Verzeichnis öffnen**: Öffnet den Ordner mit generierten Plattform-Prompts
6. **Main Prompt Verzeichnis öffnen**: Öffnet den Ordner mit allen System-Prompts
7. **Beenden**: Verlässt das Programm

### Neuen Prompt erstellen

1. Wählen Sie Option 2 im Hauptmenü
2. Wählen Sie Ihren bevorzugten Editor (vim oder nano)
3. Geben Sie einen Namen für den Prompt ein
4. Der Editor öffnet sich mit einer Vorlage
5. Bearbeiten Sie die Vorlage nach Ihren Wünschen
6. Speichern und schließen Sie den Editor
7. Optional: Aktivieren Sie den neuen Prompt sofort

### Prompt-Struktur

Prompts sollten im YAML-Header folgende Informationen enthalten:

```yaml
---
name: Mein Projekt Prompt
version: 1.0
last_updated: 2025-01-15
project: mein-projekt
tags:
  - tag1
  - tag2
status: aktiv
---

# Prompt Inhalt hier...
```

### Verzeichnis-Struktur

```
/home/commander/Dokumente/Systemprompts/
├── MainPrompt.md           # Aktuell aktiver Prompt

/home/commander/Dokumente/Scripts/mainprompt-manager/
├── prompt-manager.sh      # Hauptskript
├── config.json           # Konfigurationsdatei
├── README.md             # Dokumentation
├── LICENSE               # MIT Lizenz
├── .gitignore           # Git-Ignores
├── templates/           # Alle Prompt-Templates (zentrale Verwaltung)
│   ├── projekt1-prompt.md      # Öffentliche Templates
│   ├── projekt2-prompt.md      # Werden in Git versioniert
│   └── private-templates/      # Private Templates (NICHT in Git)
│       └── mein-privat.md      # Persönliche Templates
└── platform-prompts/    # Plattform-spezifische Prompts
    └── DE-platform-prompt.md
```

## ⚙️ Konfiguration

Die Pfade sind in der Datei `config.json` konfiguriert:

```json
{
  "prompt_dir": "/home/$USER/Dokumente/Systemprompts",
  "main_prompt_filename": "MainPrompt.md",
  "template_dir": "templates",
  "default_editor": "nano",
  "language": "de"
}
```

Sie können diese über Option 3 im Hauptmenü anpassen.

## 🔧 Erweiterte Funktionen

### Template-Verwaltung

Alle Prompts werden zentral im `templates/` Ordner verwaltet:
- Neue Prompts werden dort gespeichert
- Prompt-Wechsel kopiert aus Templates
- Keine doppelten Dateien mehr
- Übersichtliche zentrale Verwaltung

## 🎯 Anwendungsfälle

1. **Projekt-Wechsel**: Schnell zwischen verschiedenen Projekt-Kontexten wechseln
2. **Prompt-Versionierung**: Verschiedene Versionen eines Prompts testen
3. **Team-Zusammenarbeit**: Gemeinsame Prompts im Team nutzen
4. **Entwicklungs-Workflow**: Unterschiedliche Prompts für Dev/Test/Prod

## 🐛 Fehlerbehebung

### Keine Prompts gefunden
- Überprüfen Sie, ob `.md` Dateien im konfigurierten Verzeichnis vorhanden sind
- Stellen Sie sicher, dass Sie Leserechte für das Verzeichnis haben

### Fehler beim Wechseln
- Überprüfen Sie die Schreibrechte im Systemprompts-Verzeichnis
- Stellen Sie sicher, dass genügend Speicherplatz für Backups vorhanden ist

## 📝 Lizenz

Dieses Projekt ist unter der MIT-Lizenz lizenziert - siehe [LICENSE](LICENSE) Datei für Details.

## 🤝 Beitragen

Beiträge sind willkommen! Bitte:

1. Forken Sie das Repository
2. Erstellen Sie einen Feature-Branch (`git checkout -b feature/AmazingFeature`)
3. Committen Sie Ihre Änderungen (`git commit -m 'Add some AmazingFeature'`)
4. Pushen Sie zum Branch (`git push origin feature/AmazingFeature`)
5. Öffnen Sie einen Pull Request

## 📞 Kontakt

Für Fragen oder Vorschläge öffnen Sie bitte ein Issue im GitHub Repository.

---

**Hinweis**: Dieses Tool wurde speziell für die Verwaltung von Claude AI System-Prompts entwickelt.

### Config bearbeiten

1. Wählen Sie Option 3 im Hauptmenü
2. Die Config öffnet sich automatisch in nano
3. Bearbeiten Sie die JSON-Config:
   - `prompt_dir`: Verzeichnis für Systemprompts
   - `main_prompt_filename`: Name der Hauptprompt-Datei
   - `template_dir`: Verzeichnis für Templates (relativ zum Skript)
4. Speichern und Tool neu starten

### Plattform-Prompt erstellen

1. Wählen Sie Option 4 im Hauptmenü
2. Überprüfen Sie die erkannten Pfade
3. Der generierte Prompt enthält:
   - Automatisch erkannten Benutzernamen
   - Korrekten Pfad zum MainPrompt
   - Deutsche Anweisungen für Claude
4. Kopieren Sie den generierten Text in die Claude-Plattform

### Verzeichnisse öffnen

**Option 5 - Plattform-Prompt Verzeichnis:**
- Öffnet den Ordner mit generierten Plattform-Prompts
- Funktioniert cross-platform (Windows/Linux/Mac)
- Verwendet automatisch den verfügbaren Dateimanager

**Option 6 - Main Prompt Verzeichnis:**
- Öffnet das konfigurierte Systemprompt-Verzeichnis
- Zeigt alle verfügbaren Prompts und Backups
- Direkter Zugriff für manuelle Bearbeitung

Das Tool erkennt automatisch:
- Linux: xdg-open, nautilus, dolphin, nemo, thunar
- Mac: open
- Windows: explorer.exe

## 🔒 Private Templates

Das Tool unterstützt private Templates für persönliche Prompts:

### Private vs. Öffentliche Templates

**Öffentliche Templates** (`templates/`):
- Werden in Git versioniert
- Für allgemeine, teilbare Prompts
- Ideal für Team-Zusammenarbeit

**Private Templates** (`templates/private-templates/`):
- Werden NICHT in Git versioniert (.gitignore)
- Für persönliche/vertrauliche Prompts
- Bleiben lokal auf Ihrem System

### Verwendung

1. **Beim Erstellen**: Wählen Sie ob der Prompt privat sein soll
2. **In der Übersicht**: Private Prompts sind mit "(PRIVAT)" gekennzeichnet
3. **Beim Wechseln**: Funktioniert identisch für beide Typen

### Hinweis für Beiträge

Wenn Sie zum Projekt beitragen möchten:
- Nutzen Sie private Templates für persönliche Systemprompts
- Nur allgemeine, teilbare Prompts gehören in den öffentlichen Ordner
- Private Templates werden automatisch von Git ignoriert
## 🌍 Sprachen / Languages

Das Tool unterstützt:
- 🇩🇪 **Deutsch** (Standard)
- 🇬🇧 **English**

Die Sprache kann jederzeit über das Hauptmenü gewechselt werden.

## 📁 Verzeichnisstruktur / Directory Structure

```
mainprompt-manager/
├── prompt-manager.sh      # Hauptskript / Main script
├── config.json           # Konfiguration / Configuration
├── README.md             # Dokumentation / Documentation
├── LICENSE               # MIT Lizenz / MIT License
├── .gitignore           # Git-Ignores
├── templates/           # Template-Verzeichnis / Template directory
│   ├── de-deutsch/      # Deutsche Templates / German templates
│   │   ├── main-prompts/
│   │   ├── platform-prompts/
│   │   └── private-templates/
│   └── en-english/      # Englische Templates / English templates
│       ├── main-prompts/
│       ├── platform-prompts/
│       └── private-templates/
└── platform-prompts/    # Generierte Plattform-Prompts / Generated platform prompts
```