#!/bin/bash

# Mainprompt Manager
# Verwaltet und wechselt zwischen verschiedenen System-Prompts

# Konfiguration
PROMPT_DIR="/home/commander/Dokumente/Systemprompts"
MAIN_PROMPT="MainPrompt.md"
BACKUP_DIR="$PROMPT_DIR/backups"

# Farben für bessere Lesbarkeit
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Backup-Verzeichnis erstellen falls nicht vorhanden
mkdir -p "$BACKUP_DIR"

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
# Hauptprogramm
main() {
    # Header anzeigen
    show_header
    
    # Aktuellen Prompt anzeigen
    show_current_prompt
    
    # Verfügbare Prompts auflisten
    list_prompts
    
    # Wenn keine Prompts gefunden wurden
    if [ ${#prompts[@]} -eq 0 ]; then
        echo -e "${RED}Keine Prompts gefunden in: $PROMPT_DIR${NC}"
        echo -e "${YELLOW}Hinweis: Legen Sie .md Dateien in diesem Verzeichnis ab.${NC}"
        exit 1
    fi
    
    # Benutzer-Eingabe
    echo -e "${YELLOW}Wählen Sie einen Prompt (Nummer eingeben) oder 'q' zum Beenden:${NC}"
    read -p "> " choice
    
    # Beenden bei 'q'
    if [ "$choice" == "q" ] || [ "$choice" == "Q" ]; then
        echo -e "${BLUE}Auf Wiedersehen!${NC}"
        exit 0
    fi
    
    # Prompt wechseln
    switch_prompt "$choice"
}

# Skript ausführen
main

# Warte auf Eingabe bevor das Fenster geschlossen wird
echo
read -p "Drücken Sie Enter zum Beenden..."