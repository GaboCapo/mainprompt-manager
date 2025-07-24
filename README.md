# Mainprompt Manager

Ein einfaches Shell-Tool zum Verwalten und Wechseln zwischen verschiedenen System-Prompts für Claude AI.

## 🚀 Features

- **Einfacher Prompt-Wechsel**: Nummerierte Liste aller verfügbaren Prompts
- **Neue Prompts erstellen**: Interaktive Erstellung mit Editor-Auswahl (vim/nano)
- **Template-Verwaltung**: Alle Prompts werden als Templates gespeichert
- **Automatische Backups**: Sichert den aktuellen MainPrompt.md vor dem Wechsel
- **YAML-Header Support**: Zeigt Namen und Projekt-Informationen aus den Prompt-Dateien
- **Farbige Ausgabe**: Übersichtliche Darstellung mit Farb-Highlighting
- **Aktiver Prompt-Indikator**: Zeigt deutlich, welcher Prompt gerade aktiv ist
- **Hauptmenü**: Übersichtliche Navigation zwischen den Funktionen

## 📋 Voraussetzungen

- Bash Shell
- Linux/Unix System (getestet auf Ubuntu/Debian)
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
3. **Beenden**: Verlässt das Programm

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
├── projekt1-prompt.md      # Verfügbarer Prompt
├── projekt2-prompt.md      # Verfügbarer Prompt
└── backups/               # Automatische Backups
    ├── MainPrompt_backup_20250115_143022.md
    └── MainPrompt_backup_20250115_151544.md

/home/commander/Dokumente/Scripts/mainprompt-manager/
└── templates/             # Alle Prompt-Templates
    ├── projekt1-prompt.md
    ├── projekt2-prompt.md
    └── archiviert-prompt.md
```

## ⚙️ Konfiguration

Die Pfade sind in der Datei `prompt-manager.sh` konfiguriert:

```bash
PROMPT_DIR="/home/commander/Dokumente/Systemprompts"
MAIN_PROMPT="MainPrompt.md"
BACKUP_DIR="$PROMPT_DIR/backups"
TEMPLATE_DIR="$SCRIPT_DIR/templates"
```

Sie können diese bei Bedarf anpassen.

## 🔧 Erweiterte Funktionen

### Backup-Verwaltung

Alle Backups werden automatisch mit Zeitstempel im `backups/` Ordner gespeichert:
- Format: `MainPrompt_backup_YYYYMMDD_HHMMSS.md`
- Backups werden vor jedem Prompt-Wechsel erstellt
- Alte Backups müssen manuell gelöscht werden

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