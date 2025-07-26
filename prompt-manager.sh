#!/bin/bash

# Mainprompt Manager
# Verwaltet und wechselt zwischen verschiedenen System-Prompts

# Script-Verzeichnis ermitteln
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.json"

# Standard-Konfiguration
DEFAULT_PROMPT_DIR="/home/$USER/Dokumente/Systemprompts"
DEFAULT_MAIN_PROMPT="MainPrompt.md"
DEFAULT_BACKUP_DIR="backups"
DEFAULT_EDITOR="nano"

# Config laden oder erstellen
if [ -f "$CONFIG_FILE" ]; then
    # Config laden
    PROMPT_DIR=$(jq -r '.prompt_dir // "'$DEFAULT_PROMPT_DIR'"' "$CONFIG_FILE" 2>/dev/null || echo "$DEFAULT_PROMPT_DIR")
    MAIN_PROMPT=$(jq -r '.main_prompt_filename // "'$DEFAULT_MAIN_PROMPT'"' "$CONFIG_FILE" 2>/dev/null || echo "$DEFAULT_MAIN_PROMPT")
    BACKUP_DIR_NAME=$(jq -r '.backup_dir // "'$DEFAULT_BACKUP_DIR'"' "$CONFIG_FILE" 2>/dev/null || echo "$DEFAULT_BACKUP_DIR")
    DEFAULT_EDITOR_CONFIG=$(jq -r '.default_editor // "'$DEFAULT_EDITOR'"' "$CONFIG_FILE" 2>/dev/null || echo "$DEFAULT_EDITOR")
else
    # Standard-Config erstellen
    cat > "$CONFIG_FILE" << EOF
{
  "prompt_dir": "$DEFAULT_PROMPT_DIR",
  "main_prompt_filename": "$DEFAULT_MAIN_PROMPT",
  "backup_dir": "$DEFAULT_BACKUP_DIR",
  "default_editor": "$DEFAULT_EDITOR",
  "language": "de"
}
EOF
    PROMPT_DIR="$DEFAULT_PROMPT_DIR"
    MAIN_PROMPT="$DEFAULT_MAIN_PROMPT"
    BACKUP_DIR_NAME="$DEFAULT_BACKUP_DIR"
    DEFAULT_EDITOR_CONFIG="$DEFAULT_EDITOR"
fi

# Pfade setzen
BACKUP_DIR="$PROMPT_DIR/$BACKUP_DIR_NAME"
TEMPLATE_DIR="$SCRIPT_DIR/templates"
PLATFORM_PROMPTS_DIR="$SCRIPT_DIR/platform-prompts"

# Farben für bessere Lesbarkeit
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Backup-Verzeichnis, Template-Verzeichnis und Platform-Prompts erstellen falls nicht vorhanden
mkdir -p "$BACKUP_DIR"
mkdir -p "$TEMPLATE_DIR"
mkdir -p "$PLATFORM_PROMPTS_DIR"

# Wenn Prompt-Verzeichnis nicht existiert, Template-Verzeichnis verwenden
if [ ! -d "$PROMPT_DIR" ]; then
    echo -e "${YELLOW}Hinweis: Prompt-Verzeichnis nicht gefunden. Verwende Template-Verzeichnis.${NC}"
    PROMPT_DIR="$TEMPLATE_DIR"
    mkdir -p "$PROMPT_DIR"
fi

# Funktion: Header anzeigen
show_header() {
    clear
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}    Mainprompt Manager v1.0     ${NC}"
    echo -e "${BLUE}================================${NC}"
    echo
}

# Funktion: Aktuellen Prompt anzeigen
show_current_prompt() {
    if [ -f "$PROMPT_DIR/$MAIN_PROMPT" ]; then
        # Versuche den Namen aus dem YAML-Header zu extrahieren
        local current_name=$(grep "^name:" "$PROMPT_DIR/$MAIN_PROMPT" 2>/dev/null | cut -d: -f2- | xargs)
        if [ -z "$current_name" ]; then
            current_name="MainPrompt.md"
        fi
        echo -e "${GREEN}Aktueller Prompt:${NC} $current_name"
    else
        echo -e "${RED}Kein aktiver MainPrompt.md gefunden!${NC}"
    fi
    echo
}
# Funktion: Verfügbare Prompts auflisten
list_prompts() {
    echo -e "${YELLOW}Verfügbare Prompts:${NC}"
    echo "-------------------"
    
    # Array für Dateinamen
    prompts=()
    
    # Zähler
    local i=1
    
    # Alle .md Dateien finden (außer MainPrompt.md und Dateien im backup Ordner)
    while IFS= read -r file; do
        # Nur Dateiname ohne Pfad
        filename=$(basename "$file")
        
        # MainPrompt.md überspringen
        if [ "$filename" != "$MAIN_PROMPT" ]; then
            prompts+=("$file")
            
            # Versuche den Namen aus dem YAML-Header zu extrahieren
            local prompt_name=$(grep "^name:" "$file" 2>/dev/null | cut -d: -f2- | xargs)
            if [ -z "$prompt_name" ]; then
                prompt_name=$filename
            fi
            
            # Prüfe ob dies der aktive Prompt ist
            if [ -f "$PROMPT_DIR/$MAIN_PROMPT" ]; then
                if diff -q "$file" "$PROMPT_DIR/$MAIN_PROMPT" >/dev/null 2>&1; then
                    echo -e "  ${GREEN}[$i]${NC} $prompt_name ${GREEN}(AKTIV)${NC}"
                else
                    echo -e "  ${BLUE}[$i]${NC} $prompt_name"
                fi
            else
                echo -e "  ${BLUE}[$i]${NC} $prompt_name"
            fi
            
            ((i++))
        fi
    done < <(find "$PROMPT_DIR" -maxdepth 1 -name "*.md" -type f | sort)
    
    echo
}
# Funktion: Prompt wechseln
switch_prompt() {
    local selection=$1
    
    # Validierung
    if ! [[ "$selection" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Fehler: Bitte eine gültige Zahl eingeben!${NC}"
        return 1
    fi
    
    # Prüfen ob Auswahl im gültigen Bereich
    if [ "$selection" -lt 1 ] || [ "$selection" -gt "${#prompts[@]}" ]; then
        echo -e "${RED}Fehler: Ungültige Auswahl!${NC}"
        return 1
    fi
    
    # Gewählte Datei
    local selected_file="${prompts[$((selection-1))]}"
    local selected_name=$(basename "$selected_file")
    
    # Backup des aktuellen MainPrompt erstellen (falls vorhanden)
    if [ -f "$PROMPT_DIR/$MAIN_PROMPT" ]; then
        local timestamp=$(date +%Y%m%d_%H%M%S)
        local backup_file="$BACKUP_DIR/MainPrompt_backup_$timestamp.md"
        cp "$PROMPT_DIR/$MAIN_PROMPT" "$backup_file"
        echo -e "${YELLOW}Backup erstellt: $(basename "$backup_file")${NC}"
    fi
    
    # Neuen Prompt aktivieren
    cp "$selected_file" "$PROMPT_DIR/$MAIN_PROMPT"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Prompt erfolgreich gewechselt zu: $selected_name${NC}"
        
        # Info aus dem neuen Prompt anzeigen
        local prompt_name=$(grep "^name:" "$PROMPT_DIR/$MAIN_PROMPT" 2>/dev/null | cut -d: -f2- | xargs)
        local prompt_project=$(grep "^project:" "$PROMPT_DIR/$MAIN_PROMPT" 2>/dev/null | cut -d: -f2- | xargs)
        
        if [ -n "$prompt_name" ]; then
            echo -e "${BLUE}Name: $prompt_name${NC}"
        fi
        if [ -n "$prompt_project" ]; then
            echo -e "${BLUE}Projekt: $prompt_project${NC}"
        fi
    else
        echo -e "${RED}Fehler beim Wechseln des Prompts!${NC}"
        return 1
    fi
}

# Funktion: Neuen Prompt erstellen
create_new_prompt() {
    echo -e "${YELLOW}Neuen Prompt erstellen${NC}"
    echo "====================="
    echo
    
    # Namen erfragen
    echo -e "${BLUE}Geben Sie einen Namen für den neuen Prompt ein:${NC}"
    echo "(z.B. 'Webentwicklung Prompt', 'Data Science Assistant')"
    read -p "> " prompt_name
    
    if [ -z "$prompt_name" ]; then
        echo -e "${RED}Fehler: Name darf nicht leer sein!${NC}"
        return 1
    fi
    
    # Dateinamen generieren (Leerzeichen durch Bindestriche ersetzen, lowercase)
    filename=$(echo "$prompt_name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/[^a-z0-9-]//g')
    filename="${filename}.md"
    
    # Temporäre Datei mit Template erstellen
    temp_file="/tmp/new_prompt_$$.md"
    cat > "$temp_file" << EOF
---
name: $prompt_name
version: 1.0
last_updated: $(date +%Y-%m-%d)
project: $(echo "$filename" | sed 's/\.md$//')
tags:
  - tag1
  - tag2
status: aktiv
---

# $prompt_name

## Kontext
[Beschreiben Sie hier den Kontext und Zweck dieses Prompts]

## Hauptaufgaben
1. [Aufgabe 1]
2. [Aufgabe 2]
3. [Aufgabe 3]

## Spezialisierung
- [Spezieller Fokus 1]
- [Spezieller Fokus 2]

## Wichtige Regeln
- [Regel 1]
- [Regel 2]

## Beispiele
[Fügen Sie hier Beispiele oder spezielle Anweisungen ein]
EOF
    
    # Editor öffnen (immer nano)
    nano "$temp_file"
    
    # Prüfen ob Datei gespeichert wurde
    if [ -s "$temp_file" ]; then
        # In Template-Ordner speichern
        cp "$temp_file" "$TEMPLATE_DIR/$filename"
        
        # Optional: Auch direkt als verfügbaren Prompt speichern
        cp "$temp_file" "$PROMPT_DIR/$filename"
        
        echo
        echo -e "${GREEN}✓ Prompt erfolgreich erstellt!${NC}"
        echo -e "${BLUE}Gespeichert als:${NC}"
        echo "  - Template: $TEMPLATE_DIR/$filename"
        echo "  - Prompt: $PROMPT_DIR/$filename"
        
        # Aufräumen
        rm "$temp_file"
        
        # Fragen ob direkt aktiviert werden soll
        echo
        echo -e "${YELLOW}Möchten Sie diesen Prompt direkt aktivieren? (j/n)${NC}"
        read -p "> " activate
        
        if [[ "$activate" =~ ^[jJyY]$ ]]; then
            # Backup erstellen
            if [ -f "$PROMPT_DIR/$MAIN_PROMPT" ]; then
                local timestamp=$(date +%Y%m%d_%H%M%S)
                local backup_file="$BACKUP_DIR/MainPrompt_backup_$timestamp.md"
                cp "$PROMPT_DIR/$MAIN_PROMPT" "$backup_file"
                echo -e "${YELLOW}Backup erstellt: $(basename "$backup_file")${NC}"
            fi
            
            # Aktivieren
            cp "$PROMPT_DIR/$filename" "$PROMPT_DIR/$MAIN_PROMPT"
            echo -e "${GREEN}✓ Neuer Prompt wurde aktiviert!${NC}"
        fi
    else
        echo -e "${RED}Abgebrochen - keine Datei erstellt.${NC}"
        rm -f "$temp_file"
    fi
}

# Funktion: Config bearbeiten
edit_config() {
    echo -e "${YELLOW}Config-Datei bearbeiten${NC}"
    echo "====================="
    echo
    
    # Aktuelle Config anzeigen
    echo -e "${BLUE}Aktuelle Konfiguration:${NC}"
    echo "- Prompt-Verzeichnis: $PROMPT_DIR"
    echo "- MainPrompt-Dateiname: $MAIN_PROMPT"
    echo "- Backup-Verzeichnis: $BACKUP_DIR_NAME"
    echo "- Standard-Editor: nano"
    echo
    
    echo -e "${YELLOW}Öffne Config-Datei mit nano...${NC}"
    sleep 1
    
    # Config mit nano bearbeiten
    nano "$CONFIG_FILE"
    
    echo
    echo -e "${GREEN}✓ Config wurde bearbeitet!${NC}"
    echo -e "${YELLOW}Hinweis: Starten Sie das Tool neu, um die Änderungen zu übernehmen.${NC}"
}

# Funktion: Plattform-Prompt erstellen
create_platform_prompt() {
    echo -e "${YELLOW}Plattform-Prompt erstellen (DE)${NC}"
    echo "================================"
    echo
    
    # Aktuellen Pfad und Benutzer anzeigen
    local current_user="$USER"
    local actual_prompt_path="$PROMPT_DIR/$MAIN_PROMPT"
    
    # Pfad mit Benutzername erstellen
    local user_prompt_path=$(echo "$actual_prompt_path" | sed "s|/home/[^/]*|/home/$current_user|")
    
    echo -e "${BLUE}Erkannte Informationen:${NC}"
    echo "- Benutzername: $current_user"
    echo "- MainPrompt-Pfad: $user_prompt_path"
    echo
    
    # Bestätigung
    echo -e "${YELLOW}Ist der Pfad korrekt? (j/n)${NC}"
    read -p "> " confirm
    
    if [[ ! "$confirm" =~ ^[jJyY]$ ]]; then
        echo -e "${RED}Abgebrochen. Bitte passen Sie zuerst die Config an (Option 3).${NC}"
        return 1
    fi
    
    # Plattform-Prompt generieren
    local platform_prompt_file="$PLATFORM_PROMPTS_DIR/DE-platform-prompt.md"
    
    cat > "$platform_prompt_file" << EOF
# Plattform-Prompt für Claude (Deutsch)

Führe vor jeder Antwort einen Reasoning Prozess durch, wo du deine Vorgehensweise Strategie noch einmal zusammenfasst. 

Lese dir vorab immer über die Erweiterung Desktop Commander ~/${user_prompt_path#/home/$current_user/} durch dieser definiert den für dich relevanten Kontext.

Solltest du Probleme haben stoppe jederzeit und wir lösen zusammen den Fehler.

Ich will bevor du irgendwelche Methoden Ansätze ausprobiert mich immer vorher fragst ob wir die machen sollen.

---

## Hinweise zur Verwendung:

1. Dieser Plattform-Prompt wurde automatisch generiert für:
   - Benutzer: $current_user
   - MainPrompt-Pfad: $user_prompt_path

2. Kopieren Sie den obigen Text (ohne diese Hinweise) und fügen Sie ihn in die Claude-Plattform ein.

3. Der Prompt sorgt dafür, dass Claude:
   - Vor jeder Antwort seinen Denkprozess durchführt
   - Den MainPrompt automatisch liest
   - Bei Problemen stoppt und nachfragt
   - Vor neuen Ansätzen um Erlaubnis fragt

Generiert am: $(date +"%Y-%m-%d %H:%M:%S")
EOF
    
    echo -e "${GREEN}✓ Plattform-Prompt wurde erstellt!${NC}"
    echo -e "${BLUE}Gespeichert unter: $platform_prompt_file${NC}"
    echo
    echo -e "${YELLOW}Anleitung:${NC}"
    echo "1. Öffnen Sie die Datei: $platform_prompt_file"
    echo "2. Kopieren Sie den Text bis zur Trennlinie (---)"
    echo "3. Fügen Sie ihn in die Claude-Plattform ein"
    echo
    
    # Optional: Datei direkt anzeigen
    echo -e "${YELLOW}Möchten Sie den Prompt jetzt anzeigen? (j/n)${NC}"
    read -p "> " show
    
    if [[ "$show" =~ ^[jJyY]$ ]]; then
        echo
        echo -e "${BLUE}=== PLATTFORM-PROMPT (zum Kopieren) ===${NC}"
        sed -n '1,/^---$/p' "$platform_prompt_file" | head -n -1
        echo -e "${BLUE}=======================================${NC}"
    fi
}

# Funktion: Verzeichnis öffnen (Cross-Platform)
open_directory() {
    local dir="$1"
    local dir_name="$2"
    
    if [ ! -d "$dir" ]; then
        echo -e "${RED}Fehler: Verzeichnis existiert nicht: $dir${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Öffne $dir_name...${NC}"
    
    # Betriebssystem erkennen
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        if command -v xdg-open &> /dev/null; then
            xdg-open "$dir" 2>/dev/null &
        elif command -v nautilus &> /dev/null; then
            nautilus "$dir" 2>/dev/null &
        elif command -v dolphin &> /dev/null; then
            dolphin "$dir" 2>/dev/null &
        elif command -v nemo &> /dev/null; then
            nemo "$dir" 2>/dev/null &
        elif command -v thunar &> /dev/null; then
            thunar "$dir" 2>/dev/null &
        else
            echo -e "${RED}Kein Dateimanager gefunden!${NC}"
            echo -e "${BLUE}Verzeichnis: $dir${NC}"
            return 1
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # Mac OS
        open "$dir" 2>/dev/null &
    elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        # Windows
        explorer.exe "$dir" 2>/dev/null &
    else
        echo -e "${RED}Unbekanntes Betriebssystem: $OSTYPE${NC}"
        echo -e "${BLUE}Verzeichnis: $dir${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✓ Dateimanager wurde geöffnet${NC}"
}

# Funktion: Plattform-Prompt Verzeichnis öffnen
open_platform_prompts_dir() {
    echo -e "${YELLOW}Plattform-Prompt Verzeichnis öffnen${NC}"
    echo "===================================="
    echo
    open_directory "$PLATFORM_PROMPTS_DIR" "Plattform-Prompts Verzeichnis"
}

# Funktion: Main Prompt Verzeichnis öffnen
open_main_prompt_dir() {
    echo -e "${YELLOW}Main Prompt Verzeichnis öffnen${NC}"
    echo "==============================="
    echo
    open_directory "$PROMPT_DIR" "Main Prompt Verzeichnis"
}
# Funktion: Hauptmenü anzeigen
show_main_menu() {
    echo -e "${YELLOW}Hauptmenü:${NC}"
    echo "==========="
    echo "  [1] Prompt wechseln"
    echo "  [2] Neuen Prompt erstellen"
    echo "  [3] Config bearbeiten"
    echo "  [4] Plattform-Prompt erstellen"
    echo "  [5] Plattform-Prompt Verzeichnis öffnen"
    echo "  [6] Main Prompt Verzeichnis öffnen"
    echo "  [q] Beenden"
    echo
}

# Funktion: Prompt-Wechsel Menü
prompt_switch_menu() {
    # Verfügbare Prompts auflisten
    list_prompts
    
    # Wenn keine Prompts gefunden wurden
    if [ ${#prompts[@]} -eq 0 ]; then
        echo -e "${RED}Keine Prompts gefunden in: $PROMPT_DIR${NC}"
        echo -e "${YELLOW}Hinweis: Erstellen Sie einen neuen Prompt über das Hauptmenü.${NC}"
        return 1
    fi
    
    # Benutzer-Eingabe
    echo -e "${YELLOW}Wählen Sie einen Prompt (Nummer eingeben) oder 'b' für zurück:${NC}"
    read -p "> " choice
    
    # Zurück bei 'b'
    if [ "$choice" == "b" ] || [ "$choice" == "B" ]; then
        return 0
    fi
    
    # Prompt wechseln
    switch_prompt "$choice"
    
    # Kurz warten
    sleep 2
}

# Hauptprogramm
main() {
    while true; do
        # Header anzeigen
        show_header
        
        # Aktuellen Prompt anzeigen
        show_current_prompt
        
        # Hauptmenü anzeigen
        show_main_menu
        
        # Benutzer-Eingabe
        read -p "> " main_choice
        
        case $main_choice in
            1)
                # Prompt wechseln
                prompt_switch_menu
                ;;
            2)
                # Neuen Prompt erstellen
                create_new_prompt
                echo
                read -p "Drücken Sie Enter zum Fortfahren..."
                ;;
            3)
                # Config bearbeiten
                edit_config
                echo
                read -p "Drücken Sie Enter zum Fortfahren..."
                ;;
            4)
                # Plattform-Prompt erstellen
                create_platform_prompt
                echo
                read -p "Drücken Sie Enter zum Fortfahren..."
                ;;
            5)
                # Plattform-Prompt Verzeichnis öffnen
                open_platform_prompts_dir
                echo
                read -p "Drücken Sie Enter zum Fortfahren..."
                ;;
            6)
                # Main Prompt Verzeichnis öffnen
                open_main_prompt_dir
                echo
                read -p "Drücken Sie Enter zum Fortfahren..."
                ;;
            q|Q)
                echo -e "${BLUE}Auf Wiedersehen!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Ungültige Auswahl!${NC}"
                sleep 1
                ;;
        esac
    done
}

# Skript ausführen
main