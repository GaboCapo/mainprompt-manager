#!/bin/bash

# Mainprompt Manager v2.0 - Multilingual Version
# Verwaltet und wechselt zwischen verschiedenen System-Prompts

# Script-Verzeichnis ermitteln
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.json"

# Standard-Konfiguration
DEFAULT_PROMPT_DIR="/home/$USER/Dokumente/Systemprompts"
DEFAULT_MAIN_PROMPT="MainPrompt.md"
DEFAULT_TEMPLATE_DIR="templates"
DEFAULT_EDITOR="nano"
DEFAULT_LANGUAGE="de"
DEFAULT_UI_LANGUAGE="de"

# Config laden oder erstellen
if [ -f "$CONFIG_FILE" ]; then
    # Config laden
    PROMPT_DIR=$(jq -r '.prompt_dir // "'$DEFAULT_PROMPT_DIR'"' "$CONFIG_FILE" 2>/dev/null || echo "$DEFAULT_PROMPT_DIR")
    MAIN_PROMPT=$(jq -r '.main_prompt_filename // "'$DEFAULT_MAIN_PROMPT'"' "$CONFIG_FILE" 2>/dev/null || echo "$DEFAULT_MAIN_PROMPT")
    TEMPLATE_DIR_NAME=$(jq -r '.template_dir // "'$DEFAULT_TEMPLATE_DIR'"' "$CONFIG_FILE" 2>/dev/null || echo "$DEFAULT_TEMPLATE_DIR")
    DEFAULT_EDITOR_CONFIG=$(jq -r '.default_editor // "'$DEFAULT_EDITOR'"' "$CONFIG_FILE" 2>/dev/null || echo "$DEFAULT_EDITOR")
    LANGUAGE=$(jq -r '.language // "'$DEFAULT_LANGUAGE'"' "$CONFIG_FILE" 2>/dev/null || echo "$DEFAULT_LANGUAGE")
    UI_LANGUAGE=$(jq -r '.ui_language // "'$DEFAULT_UI_LANGUAGE'"' "$CONFIG_FILE" 2>/dev/null || echo "$DEFAULT_UI_LANGUAGE")
else
    # Standard-Config erstellen
    cat > "$CONFIG_FILE" << EOF
{
  "prompt_dir": "$DEFAULT_PROMPT_DIR",
  "main_prompt_filename": "$DEFAULT_MAIN_PROMPT",
  "template_dir": "$DEFAULT_TEMPLATE_DIR",
  "default_editor": "$DEFAULT_EDITOR",
  "language": "$DEFAULT_LANGUAGE",
  "ui_language": "$DEFAULT_UI_LANGUAGE"
}
EOF
    PROMPT_DIR="$DEFAULT_PROMPT_DIR"
    MAIN_PROMPT="$DEFAULT_MAIN_PROMPT"
    TEMPLATE_DIR_NAME="$DEFAULT_TEMPLATE_DIR"
    DEFAULT_EDITOR_CONFIG="$DEFAULT_EDITOR"
    LANGUAGE="$DEFAULT_LANGUAGE"
    UI_LANGUAGE="$DEFAULT_UI_LANGUAGE"
fi

# Pfade setzen
TEMPLATE_DIR="$SCRIPT_DIR/$TEMPLATE_DIR_NAME"
PLATFORM_PROMPTS_DIR="$SCRIPT_DIR/platform-prompts"

# Sprach-spezifische Pfade
if [ "$LANGUAGE" = "de" ]; then
    LANG_DIR="de-deutsch"
    LANG_NAME="Deutsch"
else
    LANG_DIR="en-english"
    LANG_NAME="English"
fi

MAIN_TEMPLATES_DIR="$TEMPLATE_DIR/$LANG_DIR/main-prompts"
PLATFORM_TEMPLATES_DIR="$TEMPLATE_DIR/$LANG_DIR/platform-prompts"
PRIVATE_TEMPLATES_DIR="$TEMPLATE_DIR/$LANG_DIR/private-templates"

# Farben für bessere Lesbarkeit
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Template-Verzeichnisse erstellen falls nicht vorhanden
mkdir -p "$TEMPLATE_DIR"
mkdir -p "$PLATFORM_PROMPTS_DIR"
mkdir -p "$MAIN_TEMPLATES_DIR"
mkdir -p "$PLATFORM_TEMPLATES_DIR"
mkdir -p "$PRIVATE_TEMPLATES_DIR"

# Wenn Prompt-Verzeichnis nicht existiert, erstellen
if [ ! -d "$PROMPT_DIR" ]; then
    echo -e "${YELLOW}Hinweis: Prompt-Verzeichnis wird erstellt: $PROMPT_DIR${NC}"
    mkdir -p "$PROMPT_DIR"
fi

# Sprachübersetzungen
declare -A TEXTS_DE=(
    ["title"]="Mainprompt Manager v2.0"
    ["current_prompt"]="Aktueller Main Prompt:"
    ["main_menu"]="Hauptmenü:"
    ["switch_prompt"]="Main Prompt wechseln"
    ["create_prompt"]="Neuen Main Prompt erstellen"
    ["edit_config"]="Config bearbeiten"
    ["create_platform"]="Plattform-Prompt erstellen/anzeigen"
    ["open_platform_dir"]="Plattform-Prompt Verzeichnis öffnen"
    ["open_main_dir"]="Main Prompt Verzeichnis öffnen"
    ["change_language"]="Change Language (EN)"
    ["quit"]="Beenden"
    ["available_prompts"]="Verfügbare Main Prompts:"
    ["public_templates"]="Öffentliche Templates:"
    ["private_templates"]="Private Templates:"
    ["active"]="AKTIV"
    ["private"]="PRIVAT"
    ["choose_prompt"]="Wählen Sie einen Main Prompt (Nummer eingeben) oder 'b' für zurück:"
    ["invalid_input"]="Fehler: Bitte eine gültige Zahl eingeben!"
    ["invalid_selection"]="Fehler: Ungültige Auswahl!"
    ["prompt_switched"]="✓ Main Prompt erfolgreich gewechselt!"
    ["name"]="Name:"
    ["project"]="Projekt:"
    ["create_new_prompt"]="Neuen Main Prompt erstellen"
    ["enter_name"]="Geben Sie einen Namen für den neuen Main Prompt ein:"
    ["name_empty"]="Fehler: Name darf nicht leer sein!"
    ["duplicate_error"]="Fehler: Ein Main Prompt mit diesem Namen existiert bereits!"
    ["choose_different"]="Bitte wählen Sie einen anderen Namen."
    ["private_question"]="Soll dieser Main Prompt privat sein?"
    ["private_info"]="(Private Prompts werden nicht in Git versioniert)"
    ["yes_private"]="Ja, privat"
    ["no_public"]="Nein, öffentlich"
    ["prompt_created"]="✓ Main Prompt erfolgreich erstellt!"
    ["saved_private"]="Gespeichert als privates Template:"
    ["saved_public"]="Gespeichert als öffentliches Template:"
    ["activate_question"]="Möchten Sie diesen Main Prompt direkt aktivieren? (j/n)"
    ["prompt_activated"]="✓ Neuer Main Prompt wurde aktiviert!"
    ["cancelled"]="Abgebrochen - keine Datei erstellt."
    ["current_config"]="Aktuelle Konfiguration:"
    ["prompt_directory"]="Prompt-Verzeichnis:"
    ["main_prompt_file"]="MainPrompt-Dateiname:"
    ["template_directory"]="Template-Verzeichnis:"
    ["default_editor"]="Standard-Editor: nano"
    ["opening_config"]="Öffne Config-Datei mit nano..."
    ["config_edited"]="✓ Config wurde bearbeitet!"
    ["restart_hint"]="Hinweis: Starten Sie das Tool neu, um die Änderungen zu übernehmen."
    ["platform_prompt_title"]="Plattform-Prompt erstellen/anzeigen"
    ["choose_template"]="Wählen Sie ein Plattform-Prompt Template:"
    ["no_templates"]="Keine Templates gefunden!"
    ["detected_info"]="Erkannte Informationen:"
    ["username"]="Benutzername:"
    ["main_prompt_path"]="MainPrompt-Pfad:"
    ["path_correct"]="Ist der Pfad korrekt? (j/n)"
    ["aborted_config"]="Abgebrochen. Bitte passen Sie zuerst die Config an (Option 3)."
    ["platform_created"]="✓ Plattform-Prompt wurde erstellt!"
    ["saved_under"]="Gespeichert unter:"
    ["instructions"]="Anleitung:"
    ["open_file"]="1. Öffnen Sie die Datei:"
    ["copy_text"]="2. Kopieren Sie den Text bis zur Trennlinie (---)"
    ["paste_claude"]="3. Fügen Sie ihn in die Claude-Plattform ein"
    ["show_prompt"]="Möchten Sie den Prompt jetzt anzeigen? (j/n)"
    ["platform_prompt_copy"]="=== PLATTFORM-PROMPT (zum Kopieren) ==="
    ["opening_directory"]="Öffne"
    ["file_manager_opened"]="✓ Dateimanager wurde geöffnet"
    ["no_file_manager"]="Kein Dateimanager gefunden!"
    ["directory"]="Verzeichnis:"
    ["dir_not_exist"]="Fehler: Verzeichnis existiert nicht:"
    ["unknown_os"]="Unbekanntes Betriebssystem:"
    ["platform_dir_title"]="Plattform-Prompt Verzeichnis öffnen"
    ["main_dir_title"]="Main Prompt Verzeichnis öffnen"
    ["goodbye"]="Auf Wiedersehen!"
    ["press_enter"]="Drücken Sie Enter zum Fortfahren..."
    ["current_language"]="Aktuelle Sprache:"
    ["language_changed"]="Sprache wurde geändert zu:"
    ["choose_language"]="Wählen Sie eine Sprache:"
)

declare -A TEXTS_EN=(
    ["title"]="Mainprompt Manager v2.0"
    ["current_prompt"]="Current Main Prompt:"
    ["main_menu"]="Main Menu:"
    ["switch_prompt"]="Switch Main Prompt"
    ["create_prompt"]="Create New Main Prompt"
    ["edit_config"]="Edit Config"
    ["create_platform"]="Create/Show Platform Prompt"
    ["open_platform_dir"]="Open Platform Prompt Directory"
    ["open_main_dir"]="Open Main Prompt Directory"
    ["change_language"]="Change Language (DE)"
    ["quit"]="Quit"
    ["available_prompts"]="Available Main Prompts:"
    ["public_templates"]="Public Templates:"
    ["private_templates"]="Private Templates:"
    ["active"]="ACTIVE"
    ["private"]="PRIVATE"
    ["choose_prompt"]="Choose a Main Prompt (enter number) or 'b' to go back:"
    ["invalid_input"]="Error: Please enter a valid number!"
    ["invalid_selection"]="Error: Invalid selection!"
    ["prompt_switched"]="✓ Main Prompt successfully switched!"
    ["name"]="Name:"
    ["project"]="Project:"
    ["create_new_prompt"]="Create New Main Prompt"
    ["enter_name"]="Enter a name for the new Main Prompt:"
    ["name_empty"]="Error: Name cannot be empty!"
    ["duplicate_error"]="Error: A Main Prompt with this name already exists!"
    ["choose_different"]="Please choose a different name."
    ["private_question"]="Should this Main Prompt be private?"
    ["private_info"]="(Private prompts are not versioned in Git)"
    ["yes_private"]="Yes, private"
    ["no_public"]="No, public"
    ["prompt_created"]="✓ Main Prompt successfully created!"
    ["saved_private"]="Saved as private template:"
    ["saved_public"]="Saved as public template:"
    ["activate_question"]="Would you like to activate this Main Prompt now? (y/n)"
    ["prompt_activated"]="✓ New Main Prompt has been activated!"
    ["cancelled"]="Cancelled - no file created."
    ["current_config"]="Current Configuration:"
    ["prompt_directory"]="Prompt Directory:"
    ["main_prompt_file"]="MainPrompt Filename:"
    ["template_directory"]="Template Directory:"
    ["default_editor"]="Default Editor: nano"
    ["opening_config"]="Opening config file with nano..."
    ["config_edited"]="✓ Config has been edited!"
    ["restart_hint"]="Note: Restart the tool to apply changes."
    ["platform_prompt_title"]="Create/Show Platform Prompt"
    ["choose_template"]="Choose a Platform Prompt Template:"
    ["no_templates"]="No templates found!"
    ["detected_info"]="Detected Information:"
    ["username"]="Username:"
    ["main_prompt_path"]="MainPrompt Path:"
    ["path_correct"]="Is the path correct? (y/n)"
    ["aborted_config"]="Aborted. Please adjust the config first (Option 3)."
    ["platform_created"]="✓ Platform Prompt has been created!"
    ["saved_under"]="Saved under:"
    ["instructions"]="Instructions:"
    ["open_file"]="1. Open the file:"
    ["copy_text"]="2. Copy the text up to the separator line (---)"
    ["paste_claude"]="3. Paste it into the Claude platform"
    ["show_prompt"]="Would you like to display the prompt now? (y/n)"
    ["platform_prompt_copy"]="=== PLATFORM PROMPT (for copying) ==="
    ["opening_directory"]="Opening"
    ["file_manager_opened"]="✓ File manager opened"
    ["no_file_manager"]="No file manager found!"
    ["directory"]="Directory:"
    ["dir_not_exist"]="Error: Directory does not exist:"
    ["unknown_os"]="Unknown operating system:"
    ["platform_dir_title"]="Open Platform Prompt Directory"
    ["main_dir_title"]="Open Main Prompt Directory"
    ["goodbye"]="Goodbye!"
    ["press_enter"]="Press Enter to continue..."
    ["current_language"]="Current Language:"
    ["language_changed"]="Language has been changed to:"
    ["choose_language"]="Choose a language:"
)

# Funktion zum Abrufen von Texten
get_text() {
    local key=$1
    if [ "$UI_LANGUAGE" = "de" ]; then
        echo "${TEXTS_DE[$key]}"
    else
        echo "${TEXTS_EN[$key]}"
    fi
}
# Funktion: Header anzeigen
show_header() {
    clear
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}    $(get_text "title")     ${NC}"
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
        echo -e "${GREEN}$(get_text "current_prompt")${NC} $current_name"
    else
        echo -e "${RED}$(get_text "current_prompt") -${NC}"
    fi
    echo
}

# Funktion: Hauptmenü anzeigen
show_main_menu() {
    echo -e "${YELLOW}$(get_text "main_menu")${NC}"
    echo "==========="
    echo "  [1] $(get_text "switch_prompt")"
    echo "  [2] $(get_text "create_prompt")"
    echo "  [3] $(get_text "edit_config")"
    echo "  [4] $(get_text "create_platform")"
    echo "  [5] $(get_text "open_platform_dir")"
    echo "  [6] $(get_text "open_main_dir")"
    echo "  [7] $(get_text "change_language")"
    echo "  [q] $(get_text "quit")"
    echo
}
# Funktion: Verfügbare Prompts auflisten
list_prompts() {
    echo -e "${YELLOW}$(get_text "available_prompts")${NC}"
    echo "-------------------"
    
    # Array für Dateinamen
    prompts=()
    
    # Zähler
    local i=1
    
    # Erst öffentliche Templates
    echo -e "${BLUE}$(get_text "public_templates")${NC}"
    while IFS= read -r file; do
        # Nur Dateiname ohne Pfad
        filename=$(basename "$file")
        
        prompts+=("$file")
        
        # Versuche den Namen aus dem YAML-Header zu extrahieren
        local prompt_name=$(grep "^name:" "$file" 2>/dev/null | cut -d: -f2- | xargs)
        if [ -z "$prompt_name" ]; then
            prompt_name=$filename
        fi
        
        # Prüfe ob dies der aktive Prompt ist
        if [ -f "$PROMPT_DIR/$MAIN_PROMPT" ] && [ -f "$file" ]; then
            # Vergleiche Inhalt der Templates mit dem aktiven MainPrompt
            if diff -q "$file" "$PROMPT_DIR/$MAIN_PROMPT" >/dev/null 2>&1; then
                echo -e "  ${GREEN}[$i]${NC} $prompt_name ${GREEN}($(get_text "active"))${NC}"
            else
                echo -e "  ${BLUE}[$i]${NC} $prompt_name"
            fi
        else
            echo -e "  ${BLUE}[$i]${NC} $prompt_name"
        fi
        
        ((i++))
    done < <(find "$MAIN_TEMPLATES_DIR" -maxdepth 1 -name "*.md" -type f 2>/dev/null | sort)
    
    # Dann private Templates (falls vorhanden)
    if [ -d "$PRIVATE_TEMPLATES_DIR" ] && [ "$(ls -A "$PRIVATE_TEMPLATES_DIR"/*.md 2>/dev/null | grep -v README.md)" ]; then
        echo
        echo -e "${YELLOW}$(get_text "private_templates")${NC}"
        while IFS= read -r file; do
            # Nur Dateiname ohne Pfad
            filename=$(basename "$file")
            
            # README.md überspringen
            if [ "$filename" == "README.md" ]; then
                continue
            fi
            
            prompts+=("$file")
            
            # Versuche den Namen aus dem YAML-Header zu extrahieren
            local prompt_name=$(grep "^name:" "$file" 2>/dev/null | cut -d: -f2- | xargs)
            if [ -z "$prompt_name" ]; then
                prompt_name=$filename
            fi
            
            # Prüfe ob dies der aktive Prompt ist
            if [ -f "$PROMPT_DIR/$MAIN_PROMPT" ] && [ -f "$file" ]; then
                # Vergleiche Inhalt der Templates mit dem aktiven MainPrompt
                if diff -q "$file" "$PROMPT_DIR/$MAIN_PROMPT" >/dev/null 2>&1; then
                    echo -e "  ${GREEN}[$i]${NC} $prompt_name ${GREEN}($(get_text "active"), $(get_text "private"))${NC}"
                else
                    echo -e "  ${BLUE}[$i]${NC} $prompt_name ${YELLOW}($(get_text "private"))${NC}"
                fi
            else
                echo -e "  ${BLUE}[$i]${NC} $prompt_name ${YELLOW}($(get_text "private"))${NC}"
            fi
            
            ((i++))
        done < <(find "$PRIVATE_TEMPLATES_DIR" -maxdepth 1 -name "*.md" -type f 2>/dev/null | sort)
    fi
    
    echo
}
# Funktion: Prompt wechseln
switch_prompt() {
    local selection=$1
    
    # Validierung
    if ! [[ "$selection" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}$(get_text "invalid_input")${NC}"
        return 1
    fi
    
    # Prüfen ob Auswahl im gültigen Bereich
    if [ "$selection" -lt 1 ] || [ "$selection" -gt "${#prompts[@]}" ]; then
        echo -e "${RED}$(get_text "invalid_selection")${NC}"
        return 1
    fi
    
    # Gewählte Datei
    local selected_file="${prompts[$((selection-1))]}"
    local selected_name=$(basename "$selected_file")
    
    # Neuen Prompt aktivieren (aus Templates kopieren)
    cp "$selected_file" "$PROMPT_DIR/$MAIN_PROMPT"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}$(get_text "prompt_switched")${NC}"
        
        # Info aus dem neuen Prompt anzeigen
        local prompt_name=$(grep "^name:" "$PROMPT_DIR/$MAIN_PROMPT" 2>/dev/null | cut -d: -f2- | xargs)
        local prompt_project=$(grep "^project:" "$PROMPT_DIR/$MAIN_PROMPT" 2>/dev/null | cut -d: -f2- | xargs)
        
        if [ -n "$prompt_name" ]; then
            echo -e "${BLUE}$(get_text "name") $prompt_name${NC}"
        fi
        if [ -n "$prompt_project" ]; then
            echo -e "${BLUE}$(get_text "project") $prompt_project${NC}"
        fi
    else
        echo -e "${RED}$(get_text "invalid_selection")${NC}"
        return 1
    fi
}
# Funktion: Neuen Prompt erstellen
create_new_prompt() {
    echo -e "${YELLOW}$(get_text "create_new_prompt")${NC}"
    echo "====================="
    echo
    
    # Namen erfragen
    echo -e "${BLUE}$(get_text "enter_name")${NC}"
    echo "(z.B. 'Webentwicklung Prompt', 'Data Science Assistant')"
    read -p "> " prompt_name
    
    if [ -z "$prompt_name" ]; then
        echo -e "${RED}$(get_text "name_empty")${NC}"
        return 1
    fi
    
    # Dateinamen generieren (Leerzeichen durch Bindestriche ersetzen, lowercase)
    filename=$(echo "$prompt_name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/[^a-z0-9-]//g')
    filename="${filename}.md"
    
    # Prüfen ob Datei bereits existiert (in beiden Template-Ordnern)
    if [ -f "$MAIN_TEMPLATES_DIR/$filename" ] || [ -f "$PRIVATE_TEMPLATES_DIR/$filename" ]; then
        echo -e "${RED}$(get_text "duplicate_error")${NC}"
        echo -e "${YELLOW}$(get_text "choose_different")${NC}"
        return 1
    fi
    
    # Fragen ob privat oder öffentlich
    echo
    echo -e "${BLUE}$(get_text "private_question")${NC}"
    echo "$(get_text "private_info")"
    if [ "$UI_LANGUAGE" = "de" ]; then
        echo "  [j] $(get_text "yes_private")"
        echo "  [n] $(get_text "no_public")"
        local yes_pattern="^[jJyY]$"
    else
        echo "  [y] $(get_text "yes_private")"
        echo "  [n] $(get_text "no_public")"
        local yes_pattern="^[yY]$"
    fi
    read -p "> " is_private
    
    # Zielverzeichnis bestimmen
    if [[ "$is_private" =~ $yes_pattern ]]; then
        target_dir="$PRIVATE_TEMPLATES_DIR"
        mkdir -p "$target_dir"
    else
        target_dir="$MAIN_TEMPLATES_DIR"
    fi
    
    # Temporäre Datei mit Template erstellen
    temp_file="/tmp/new_prompt_$$.md"
    cat > "$temp_file" << EOF
---
name: $prompt_name
version: 1.0
last_updated: $(date +%Y-%m-%d)
project: $(echo "$filename" | sed 's/\.md$//')
language: $LANGUAGE
tags:
  - tag1
  - tag2
status: aktiv
---

# $prompt_name

## Kontext / Context
[Beschreiben Sie hier den Kontext und Zweck dieses Prompts]
[Describe the context and purpose of this prompt here]

## Hauptaufgaben / Main Tasks
1. [Aufgabe 1 / Task 1]
2. [Aufgabe 2 / Task 2]
3. [Aufgabe 3 / Task 3]

## Spezialisierung / Specialization
- [Spezieller Fokus 1 / Special Focus 1]
- [Spezieller Fokus 2 / Special Focus 2]

## Wichtige Regeln / Important Rules
- [Regel 1 / Rule 1]
- [Regel 2 / Rule 2]

## Beispiele / Examples
[Fügen Sie hier Beispiele oder spezielle Anweisungen ein]
[Add examples or special instructions here]
EOF
    # Editor öffnen (immer nano)
    nano "$temp_file"
    
    # Prüfen ob Datei gespeichert wurde
    if [ -s "$temp_file" ]; then
        # In entsprechenden Template-Ordner speichern
        cp "$temp_file" "$target_dir/$filename"
        
        echo
        echo -e "${GREEN}$(get_text "prompt_created")${NC}"
        if [[ "$is_private" =~ $yes_pattern ]]; then
            echo -e "${BLUE}$(get_text "saved_private") $target_dir/$filename${NC}"
        else
            echo -e "${BLUE}$(get_text "saved_public") $target_dir/$filename${NC}"
        fi
        
        # Aufräumen
        rm "$temp_file"
        
        # Fragen ob direkt aktiviert werden soll
        echo
        if [ "$UI_LANGUAGE" = "de" ]; then
            echo -e "${YELLOW}$(get_text "activate_question")${NC}"
            read -p "> " activate
            if [[ "$activate" =~ ^[jJyY]$ ]]; then
                activate="yes"
            fi
        else
            echo -e "${YELLOW}$(get_text "activate_question")${NC}"
            read -p "> " activate
            if [[ "$activate" =~ ^[yY]$ ]]; then
                activate="yes"
            fi
        fi
        
        if [ "$activate" = "yes" ]; then
            # Aktivieren (aus Template kopieren)
            cp "$target_dir/$filename" "$PROMPT_DIR/$MAIN_PROMPT"
            echo -e "${GREEN}$(get_text "prompt_activated")${NC}"
        fi
    else
        echo -e "${RED}$(get_text "cancelled")${NC}"
        rm -f "$temp_file"
    fi
}

# Funktion: Config bearbeiten
edit_config() {
    echo -e "${YELLOW}$(get_text "edit_config")${NC}"
    echo "====================="
    echo
    
    # Aktuelle Config anzeigen
    echo -e "${BLUE}$(get_text "current_config")${NC}"
    echo "- $(get_text "prompt_directory") $PROMPT_DIR"
    echo "- $(get_text "main_prompt_file") $MAIN_PROMPT"
    echo "- $(get_text "template_directory") $TEMPLATE_DIR_NAME"
    echo "- $(get_text "current_language") $UI_LANGUAGE"
    echo "- $(get_text "default_editor")"
    echo
    
    echo -e "${YELLOW}$(get_text "opening_config")${NC}"
    sleep 1
    
    # Config mit nano bearbeiten
    nano "$CONFIG_FILE"
    
    echo
    echo -e "${GREEN}$(get_text "config_edited")${NC}"
    echo -e "${YELLOW}$(get_text "restart_hint")${NC}"
}

# Funktion: Plattform-Prompt erstellen
create_platform_prompt() {
    echo -e "${YELLOW}$(get_text "platform_prompt_title")${NC}"
    echo "================================"
    echo
    
    # Templates auflisten
    echo -e "${BLUE}$(get_text "choose_template")${NC}"
    echo
    
    local templates=()
    local i=1
    
    while IFS= read -r file; do
        filename=$(basename "$file")
        templates+=("$file")
        
        # Template-Name extrahieren
        local template_name=$(grep "^#" "$file" 2>/dev/null | head -1 | sed 's/^# *//')
        if [ -z "$template_name" ]; then
            template_name=$filename
        fi
        
        echo "  [$i] $template_name"
        ((i++))
    done < <(find "$PLATFORM_TEMPLATES_DIR" -name "*.md" -type f 2>/dev/null | sort)
    
    if [ ${#templates[@]} -eq 0 ]; then
        echo -e "${RED}$(get_text "no_templates")${NC}"
        return 1
    fi
    
    echo
    read -p "> " selection
    
    # Validierung
    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt "${#templates[@]}" ]; then
        echo -e "${RED}$(get_text "invalid_selection")${NC}"
        return 1
    fi
    
    # Gewähltes Template
    local selected_template="${templates[$((selection-1))]}"
    
    # Aktuellen Pfad und Benutzer anzeigen
    local current_user="$USER"
    local actual_prompt_path="$PROMPT_DIR/$MAIN_PROMPT"
    
    # Pfad mit Benutzername erstellen
    local user_prompt_path=$(echo "$actual_prompt_path" | sed "s|/home/[^/]*|/home/$current_user|")
    local relative_path=$(echo "$user_prompt_path" | sed "s|/home/$current_user/|~/|")
    
    echo
    echo -e "${BLUE}$(get_text "detected_info")${NC}"
    echo "- $(get_text "username") $current_user"
    echo "- $(get_text "main_prompt_path") $relative_path"
    echo
    
    # Bestätigung
    if [ "$UI_LANGUAGE" = "de" ]; then
        echo -e "${YELLOW}$(get_text "path_correct")${NC}"
        read -p "> " confirm
        if [[ ! "$confirm" =~ ^[jJyY]$ ]]; then
            echo -e "${RED}$(get_text "aborted_config")${NC}"
            return 1
        fi
    else
        echo -e "${YELLOW}$(get_text "path_correct")${NC}"
        read -p "> " confirm
        if [[ ! "$confirm" =~ ^[yY]$ ]]; then
            echo -e "${RED}$(get_text "aborted_config")${NC}"
            return 1
        fi
    fi
    
    # Plattform-Prompt generieren
    local platform_prompt_file="$PLATFORM_PROMPTS_DIR/${LANG_DIR}-platform-prompt-$(date +%Y%m%d-%H%M%S).md"
    
    # Template lesen und Platzhalter ersetzen
    sed "s|{{MAIN_PROMPT_PATH}}|$relative_path|g" "$selected_template" > "$platform_prompt_file"
    
    echo -e "${GREEN}$(get_text "platform_created")${NC}"
    echo -e "${BLUE}$(get_text "saved_under") $platform_prompt_file${NC}"
    echo
    echo -e "${YELLOW}$(get_text "instructions")${NC}"
    echo "$(get_text "open_file") $platform_prompt_file"
    echo "$(get_text "copy_text")"
    echo "$(get_text "paste_claude")"
    echo
    
    # Optional: Datei direkt anzeigen
    if [ "$UI_LANGUAGE" = "de" ]; then
        echo -e "${YELLOW}$(get_text "show_prompt")${NC}"
        read -p "> " show
        if [[ "$show" =~ ^[jJyY]$ ]]; then
            show="yes"
        fi
    else
        echo -e "${YELLOW}$(get_text "show_prompt")${NC}"
        read -p "> " show
        if [[ "$show" =~ ^[yY]$ ]]; then
            show="yes"
        fi
    fi
    
    if [ "$show" = "yes" ]; then
        echo
        echo -e "${BLUE}$(get_text "platform_prompt_copy")${NC}"
        sed -n '1,/^---$/p' "$platform_prompt_file" | head -n -1
        echo -e "${BLUE}=======================================${NC}"
    fi
}

# Funktion: Verzeichnis öffnen (Cross-Platform)
open_directory() {
    local dir="$1"
    local dir_name="$2"
    
    if [ ! -d "$dir" ]; then
        echo -e "${RED}$(get_text "dir_not_exist") $dir${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}$(get_text "opening_directory") $dir_name...${NC}"
    
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
            echo -e "${RED}$(get_text "no_file_manager")${NC}"
            echo -e "${BLUE}$(get_text "directory") $dir${NC}"
            return 1
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # Mac OS
        open "$dir" 2>/dev/null &
    elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        # Windows
        explorer.exe "$dir" 2>/dev/null &
    else
        echo -e "${RED}$(get_text "unknown_os") $OSTYPE${NC}"
        echo -e "${BLUE}$(get_text "directory") $dir${NC}"
        return 1
    fi
    
    echo -e "${GREEN}$(get_text "file_manager_opened")${NC}"
}

# Funktion: Plattform-Prompt Verzeichnis öffnen
open_platform_prompts_dir() {
    echo -e "${YELLOW}$(get_text "platform_dir_title")${NC}"
    echo "===================================="
    echo
    open_directory "$PLATFORM_PROMPTS_DIR" "$(get_text "platform_dir_title")"
}

# Funktion: Main Prompt Verzeichnis öffnen
open_main_prompt_dir() {
    echo -e "${YELLOW}$(get_text "main_dir_title")${NC}"
    echo "==============================="
    echo
    open_directory "$PROMPT_DIR" "$(get_text "main_dir_title")"
}

# Funktion: Sprache wechseln
change_language() {
    echo -e "${YELLOW}$(get_text "change_language")${NC}"
    echo "==================="
    echo
    
    echo -e "${BLUE}$(get_text "current_language") $UI_LANGUAGE${NC}"
    echo
    echo -e "${YELLOW}$(get_text "choose_language")${NC}"
    echo "  [1] Deutsch (DE)"
    echo "  [2] English (EN)"
    echo
    read -p "> " lang_choice
    
    case $lang_choice in
        1)
            NEW_LANG="de"
            ;;
        2)
            NEW_LANG="en"
            ;;
        *)
            echo -e "${RED}$(get_text "invalid_selection")${NC}"
            return 1
            ;;
    esac
    
    # Config aktualisieren
    jq --arg lang "$NEW_LANG" '.ui_language = $lang | .language = $lang' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    
    echo -e "${GREEN}$(get_text "language_changed") $NEW_LANG${NC}"
    echo -e "${YELLOW}$(get_text "restart_hint")${NC}"
}

# Funktion: Hauptmenü anzeigen
prompt_switch_menu() {
    # Verfügbare Prompts auflisten
    list_prompts
    
    # Wenn keine Prompts gefunden wurden
    if [ ${#prompts[@]} -eq 0 ]; then
        echo -e "${RED}$(get_text "no_templates")${NC}"
        return 1
    fi
    
    # Benutzer-Eingabe
    echo -e "${YELLOW}$(get_text "choose_prompt")${NC}"
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
                read -p "$(get_text "press_enter")"
                ;;
            3)
                # Config bearbeiten
                edit_config
                echo
                read -p "$(get_text "press_enter")"
                ;;
            4)
                # Plattform-Prompt erstellen
                create_platform_prompt
                echo
                read -p "$(get_text "press_enter")"
                ;;
            5)
                # Plattform-Prompt Verzeichnis öffnen
                open_platform_prompts_dir
                echo
                read -p "$(get_text "press_enter")"
                ;;
            6)
                # Main Prompt Verzeichnis öffnen
                open_main_prompt_dir
                echo
                read -p "$(get_text "press_enter")"
                ;;
            7)
                # Sprache wechseln
                change_language
                echo
                read -p "$(get_text "press_enter")"
                ;;
            q|Q)
                echo -e "${BLUE}$(get_text "goodbye")${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}$(get_text "invalid_selection")${NC}"
                sleep 1
                ;;
        esac
    done
}

# Skript ausführen
main