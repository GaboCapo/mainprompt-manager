#!/bin/bash

# Mainprompt Manager
# Verwaltet und wechselt zwischen verschiedenen System-Prompts

# Konfiguration
PROMPT_DIR="/home/commander/Dokumente/Systemprompts"
MAIN_PROMPT="MainPrompt.md"
BACKUP_DIR="$PROMPT_DIR/backups"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/templates"

# Farben für bessere Lesbarkeit
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Backup-Verzeichnis und Template-Verzeichnis erstellen falls nicht vorhanden
mkdir -p "$BACKUP_DIR"
mkdir -p "$TEMPLATE_DIR"

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
    
    # Editor auswählen
    echo -e "${BLUE}Wählen Sie einen Editor:${NC}"
    echo "  [1] vim"
    echo "  [2] nano"
    echo
    read -p "Ihre Wahl (1 oder 2): " editor_choice
    
    case $editor_choice in
        1) EDITOR="vim" ;;
        2) EDITOR="nano" ;;
        *) 
            echo -e "${RED}Ungültige Auswahl! Verwende nano als Standard.${NC}"
            EDITOR="nano"
            ;;
    esac
    
    # Namen erfragen
    echo
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
    
    # Editor öffnen
    $EDITOR "$temp_file"
    
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
# Funktion: Hauptmenü anzeigen
show_main_menu() {
    echo -e "${YELLOW}Hauptmenü:${NC}"
    echo "==========="
    echo "  [1] Prompt wechseln"
    echo "  [2] Neuen Prompt erstellen"
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