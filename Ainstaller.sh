#!/bin/bash
# =======================================
# Web App Shortcut Creator for Browsers
# By: Ayoub Hssine A.K.A Orpheus141
# ======================================

set -euo pipefail  # Exit on error, undefined variables, and pipe failures

# Color codes for better UX
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }
print_info() { echo -e "${YELLOW}ℹ $1${NC}"; }

# Check if running on Linux with desktop environment
if [ ! -d "$HOME/.local/share/applications" ] && ! mkdir -p "$HOME/.local/share/applications" 2>/dev/null; then
    print_error "Cannot create applications directory. Are you on a Linux desktop?"
    exit 1
fi

# Browser selection
print_info "Select your browser:"
echo "1) Brave (default)"
echo "2) Google Chrome"
echo "3) Chromium"
echo "4) Firefox"
echo "5) Microsoft Edge"
read -p "Enter choice [1-5]: " browser_choice

case $browser_choice in
    2) browser_cmd="google-chrome" ;;
    3) browser_cmd="chromium" ;;
    4) browser_cmd="firefox" ;;
    5) browser_cmd="microsoft-edge" ;;
    *) browser_cmd="brave" ;;
esac

# Verify browser is installed
if ! command -v $browser_cmd &> /dev/null; then
    print_error "$browser_cmd is not installed or not in PATH"
    exit 1
fi

# App name input with validation
while true; do
    read -p "Enter the name of the web app (e.g., WhatsApp Web): " app_name
    if [ -n "$app_name" ]; then
        break
    else
        print_error "App name cannot be empty"
    fi
done

# URL input with improved validation
while true; do
    read -p "Enter the URL of the web app: " app_url
    if [[ "$app_url" =~ ^https?://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,} ]]; then
        break
    else
        print_error "Invalid URL. Must be a valid http:// or https:// address"
    fi
done

# Icon input with option to skip or download
while true; do
    print_info "Enter icon path, 'skip' for default, or 'download' for help:"
    read -p "Icon path: " icon_input
    
    if [ "$icon_input" = "skip" ]; then
        icon_path="applications-internet"  # Use system default icon
        print_info "Using default browser icon"
        break
    elif [ "$icon_input" = "download" ]; then
        print_info "Visit https://dashboardicons.com or https://iconduck.com"
        print_info "Download an icon and provide its path"
        continue
    elif [ -f "$icon_input" ]; then
        # Optionally copy icon to local directory for persistence
        icon_dir="$HOME/.local/share/icons/webapp-icons"
        mkdir -p "$icon_dir"
        icon_filename=$(basename "$icon_input")
        cp "$icon_input" "$icon_dir/$icon_filename"
        icon_path="$icon_dir/$icon_filename"
        print_success "Icon copied to $icon_path"
        break
    else
        print_error "Icon file not found at '$icon_input'"
    fi
done

# Sanitize app name for filename (remove special characters)
corrected_name=$(echo "$app_name" | tr ' ' '_' | tr -cd '[:alnum:]_-')
desktop_file="$HOME/.local/share/applications/$corrected_name.desktop"

# Check if file already exists
if [ -f "$desktop_file" ]; then
    read -p "$(print_info 'Desktop file already exists. Overwrite? (y/n): ')" overwrite
    if [[ ! "$overwrite" =~ ^[Yy]$ ]]; then
        print_info "Operation cancelled"
        exit 0
    fi
fi

# Create .desktop file with proper escaping
cat <<EOF > "$desktop_file"
[Desktop Entry]
Version=1.0
Name=$app_name
Comment=Access $app_name via $browser_cmd
Exec=$browser_cmd --app="$app_url"
Icon=$icon_path
Terminal=false
Type=Application
Categories=Network;WebBrowser;
StartupNotify=true
EOF

chmod +x "$desktop_file"

# Update desktop database (if available)
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
fi

# Success message
print_success "Web app launcher created successfully!"
echo ""
echo "Details:"
echo "  Name: $app_name"
echo "  URL: $app_url"
echo "  Browser: $browser_cmd"
echo "  Location: $desktop_file"
echo ""
print_info "You can now find '$app_name' in your application menu!"
print_info "To remove it later, delete: $desktop_file"
