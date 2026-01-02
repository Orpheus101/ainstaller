Ainstaller - Web App Shortcut Creator for Browsers

![Ainstaller Logo](ainstaller.png)

Files:
- Ainstaller.sh : installer script to create a .desktop launcher for web apps.

Install / Run:
1. Make the script executable:
   chmod +x Ainstaller.sh
2. Run the script:
   ./Ainstaller.sh

Requirements:
- A Linux desktop environment with a supported menu system
- One of these browsers installed: brave, google-chrome, chromium, firefox, microsoft-edge

Details:
- The script creates a .desktop file in ~/.local/share/applications and (optionally) copies a provided icon into ~/.local/share/icons/webapp-icons
- To remove the launcher later, delete the .desktop file shown by the script

License: MIT
