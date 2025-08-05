<img width="1280" height="640" alt="Image" src="https://github.com/user-attachments/assets/3afd4298-a941-4bef-b598-11ad5827b294" />


⚠️ WARNING: Changes made directly to the MainPrompt will NOT be saved automatically!

Currently, there is no persistent editing functionality for the MainPrompt.  
If you modify it manually, your changes will be lost when switching prompts.

💡 Workaround:  
To retain changes, you must edit the prompt *template* directly and use the prompt switcher to reload it. Be aware that this method does NOT create backups.

Persistent editing is not yet supported — use with caution.



# Mainprompt Manager v2.0 - Multilingual

Multilingual CLI tool to manage prompt sets for local AI agents with file system access.

## 🚀 Features

- **Multilingual Support**: Fully available in German and English
- **Main Prompt Management**: Clear distinction between Main Prompts and Platform Prompts
- **Platform Prompt Templates**: Predefined templates in both languages
- **Easy Prompt Switching**: Choose from all templates in the template directory
- **Create New Prompts**: Interactive creation with nano
- **Config Management**: Configurable paths and settings
- **Private Templates**: Separate management of private prompts per language
- **YAML Header Support**: Shows name and project information
- **Colored Output**: Clear display with color highlighting
- **Cross-Platform**: Works on Linux, Mac, and Windows

## 🌍 Languages / Sprachen

The tool supports:
- 🇬🇧 **English**
- 🇩🇪 **German** (Default)

The language can be changed at any time via the main menu.

## 📋 Prerequisites

- Bash Shell
- Linux/Unix System (tested on Ubuntu/Debian)
- jq (JSON processor) - for config management
- Write permissions in the system prompts directory

## 🛠️ Installation

1. Clone the repository:
```bash
git clone https://github.com/GaboCapo/mainprompt-manager.git
cd mainprompt-manager
```

2. Make executable (if not already):
```bash
chmod +x prompt-manager.sh
```

3. ( Optional: Create a symbolic link for system-wide access: ) in Development
```bash
sudo ln -s $(pwd)/prompt-manager.sh /usr/local/bin/prompt-manager
```

## 📖 Usage

### Basic Usage

```bash
./prompt-manager.sh
```

The tool shows a main menu with the following options:
1. **Switch Main Prompt**: Shows all available prompts for selection
2. **Create New Main Prompt**: Interactive creation of a new prompt
3. **Edit Config**: Adjust paths and settings
4. **Create/Show Platform Prompt**: Generate a platform-specific prompt
5. **Open Platform Prompt Directory**: Opens the folder with generated platform prompts
6. **Open Main Prompt Directory**: Opens the folder with all system prompts
7. **Change Language**: Switch between German and English
8. **Quit**: Exit the program

### Creating a New Main Prompt

1. Choose option 2 in the main menu
2. Enter a name for the prompt
3. The editor (nano) opens with a template
4. Edit the template as desired
5. Save and close the editor (Ctrl+O, Enter, Ctrl+X)
6. Optional: Activate the new prompt immediately

### Creating a Platform Prompt

1. Choose option 4 in the main menu
2. Select a template from the available options
3. Confirm the detected paths
4. The generated prompt contains:
   - Automatically detected username
   - Correct path to the MainPrompt
   - Instructions in the selected language
5. Copy the generated text to the prefered platform

### Editing Configuration

1. Choose option 3 in the main menu
2. The config opens automatically in nano
3. Edit the JSON config:
   - `prompt_dir`: Directory for system prompts
   - `main_prompt_filename`: Name of the main prompt file
   - `template_dir`: Directory for templates (relative to script)
   - `language`: Language for prompts (de/en)
   - `ui_language`: Language for UI (de/en)
4. Save and restart the tool

## 🔒 Private Templates

The tool supports private templates for personal prompts:

**Public Templates** (`templates/[language]/main-prompts/`):
- Version controlled in Git
- For general, shareable prompts
- Ideal for team collaboration

**Private Templates** (`templates/[language]/private-templates/`):
- NOT version controlled in Git (.gitignore)
- For personal/confidential prompts
- Remain local on your system

## 🎯 Use Cases

1. **Project Switching**: Quickly switch between different project contexts
2. **Prompt Versioning**: Test different versions of a prompt
3. **Team Collaboration**: Share common prompts within the team
4. **Development Workflow**: Different prompts for Dev/Test/Prod
5. **Multilingual Work**: Work with prompts in different languages

## 🐛 Troubleshooting

### No prompts found
- Check if `.md` files exist in the configured directory
- Ensure you have read permissions for the directory

### Error when switching
- Check write permissions in the system prompts directory
- Ensure sufficient disk space is available

### Language not changing
- Restart the tool after changing the language
- Check if the config.json was saved correctly

## 📝 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📞 Contact

For questions or suggestions, please open an issue in the GitHub repository.


