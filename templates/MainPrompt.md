---
name: Detaillierter Systemprompt für Claude
version: 1.9
last_updated: 2025-07-18
project: cc-augenheilung
obsidian_path: /home/commander/Dokumente/ObsidianVaults/cc-augenheilung
pdf_export_tool: /home/commander/Dokumente/Scripts/obsidian-pdf-export/obsidian-to-pdf.sh

tags:
  - Augenheilkunde
  - Operation
  - Sehnerv
status: aktiv
---

# Systemprompt Dokumentation

## 🔧 Verfügbare Tools

### Obsidian Vault PDF Export
**Skript:** `/home/commander/Dokumente/Scripts/obsidian-pdf-export/obsidian-to-pdf.sh`  
**Dokumentation:** `/home/commander/Dokumente/Scripts/obsidian-pdf-export/README.md`

**Verwendung:**
```bash
# Einfacher Export des cc-augenheilung Vaults
/home/commander/Dokumente/Scripts/obsidian-pdf-export/obsidian-to-pdf.sh /home/commander/Dokumente/ObsidianVaults/cc-augenheilung

# Mit benutzerdefinierten Optionen
/home/commander/Dokumente/Scripts/obsidian-pdf-export/obsidian-to-pdf.sh \
    --output "CC-Augenheilung-$(date +%Y-%m-%d).pdf" \
    --title "CC Augenheilung - Vollständige Dokumentation" \
    --clean \
    /home/commander/Dokumente/ObsidianVaults/cc-augenheilung
```

**Features:**
- Konvertiert kompletten Obsidian Vault zu strukturiertem PDF
- Automatische Kapitel-Gliederung basierend auf Ordner-Struktur
- Inhaltsverzeichnis, Seitennummerierung, Hyperlinks
- Robuste Fehlerbehandlung und Logging

## CHANGELOG MainPrompt

### v1.9 (2025-07-18)
- Obsidian PDF Export Tool hinzugefügt
- Tool-Referenzen und Verwendungsanweisungen dokumentiert

### v1.8 (2025-07-18)
- Basis-Konfiguration für cc-augenheilung Projekt
