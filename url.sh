#!/bin/bash

# ==============================================================================
# Script Name: URL Shortener Wrapper
# Description: Cross-distro setup and launcher for CASBERG URL Shortener
# Compliance: Bash, PEP 668 (Python Venv), Multi-OS 
# ==============================================================================

# Exit on critical failures (not strictly all, to allow fallback logic)
set -u

# 1. Directory Setup
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
VENV_DIR="$SCRIPT_DIR/venv"

# 2. Colors (Standard ANSI)
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 3. Detect Package Manager
detect_installer() {
    if command -v apt-get &> /dev/null; then
        INSTALLER="apt"
        CMD_INSTALL="sudo apt-get install -y"
        CMD_UPDATE="sudo apt-get update"
        PYTHON_DEV="python3-venv" # Debian often separates venv
    elif command -v dnf &> /dev/null; then
        INSTALLER="dnf"
        CMD_INSTALL="sudo dnf install -y"
        CMD_UPDATE="sudo dnf check-update"
        PYTHON_DEV="python3" 
    elif command -v pacman &> /dev/null; then
        INSTALLER="pacman"
        CMD_INSTALL="sudo pacman -S --noconfirm"
        CMD_UPDATE="sudo pacman -Sy"
        PYTHON_DEV="python"
    elif command -v brew &> /dev/null; then
        INSTALLER="homebrew"
        CMD_INSTALL="brew install"
        CMD_UPDATE="brew update"
        PYTHON_DEV="python"
    elif command -v pkg &> /dev/null; then
        INSTALLER="termux"
        CMD_INSTALL="pkg install -y"
        CMD_UPDATE="pkg update -y"
        PYTHON_DEV="python"
    elif command -v apk &> /dev/null; then
        INSTALLER="alpine"
        CMD_INSTALL="apk add"
        CMD_UPDATE="apk update"
        PYTHON_DEV="python3"
    else
        echo -e "${RED}[!] No supported package manager found.${NC}"
        echo "Please install python3 and python3-venv manually."
        exit 1
    fi
}

# 4. Dependency Check & Install
install_deps() {
    detect_installer
    
    # Core Dependencies (Required for functionality)
    local CORE_PKGS=("python3" "curl")
    # Add python3-venv specifically for Debian/Ubuntu
    if [[ "$INSTALLER" == "apt" ]]; then CORE_PKGS+=("python3-pip" "python3-venv"); fi

    # Visual Dependencies (Optional - Eye Candy)
    local VISUAL_PKGS=("figlet" "toilet" "boxes" "lolcat")
    
    echo -e "${BLUE}[*] Detected Package Manager: $INSTALLER${NC}"
    
    # Check Core
    local MISSING_CORE=()
    for pkg in "${CORE_PKGS[@]}"; do
        if ! command -v "${pkg%%-*}" &> /dev/null && ! dpkg -s "$pkg" &> /dev/null 2>&1; then
             MISSING_CORE+=("$pkg")
        fi
    done

    if [ ${#MISSING_CORE[@]} -gt 0 ]; then
        echo -e "${YELLOW}[*] Installing core dependencies: ${MISSING_CORE[*]}...${NC}"
        $CMD_UPDATE &> /dev/null
        $CMD_INSTALL "${MISSING_CORE[@]}"
    fi

    # Attempt Visuals (Failure is acceptable)
    if [ "$INSTALLER" != "alpine" ]; then # Alpine rarely has these
        echo -e "${BLUE}[*] Attempting to install visual extras...${NC}"
        $CMD_INSTALL "${VISUAL_PKGS[@]}" &> /dev/null || echo -e "${YELLOW}[!] Some visual tools could not be installed. Falling back to text mode.${NC}"
    fi
}

# 5. Python Virtual Environment (The only portable way to handle pip)
setup_python_env() {
    echo -e "${BLUE}[*] Setting up Python Virtual Environment...${NC}"
    
    if [ ! -d "$VENV_DIR" ]; then
        python3 -m venv "$VENV_DIR"
        if [ $? -ne 0 ]; then
            echo -e "${RED}[!] Failed to create virtual environment.${NC}"
            echo "Try running: sudo apt install python3-full (or python3-venv)"
            exit 1
        fi
    fi

    # Activate Environment
    source "$VENV_DIR/bin/activate"

    # Install Python Libs inside venv
    if ! python3 -c "import pyshorteners" &> /dev/null; then
        echo -e "${YELLOW}[*] Installing Python libraries (pyshorteners, validators)...${NC}"
        pip install pyshorteners validators --disable-pip-version-check
    fi
}

# 6. Banner Function (Graceful Degradation)
banner() {
    clear
    # Check if tools exist
    if command -v toilet &> /dev/null && command -v boxes &> /dev/null && command -v lolcat &> /dev/null; then
        toilet -f ivrit 'URL_shortner V 1.2' -w 90 | boxes -d cat -a hc -p h8 | lolcat
        echo "           Made by CASBERG" | lolcat
        echo ""
        date '+%D %T' | toilet -f term -F border --gay
    else
        # Fallback for systems without fancy tools
        echo -e "${BLUE}========================================${NC}"
        echo -e "${BLUE}       URL_shortner V2 (Lite)           ${NC}"
        echo -e "${BLUE}          Made by CASBERG               ${NC}"
        echo -e "${BLUE}       Refactored by 0n1cOn3            ${NC}"
        echo -e "${BLUE}========================================${NC}"
        echo "Time: $(date)"
    fi
    echo ""
    echo -e "${BLUE} Mail: casbergskull@gmail.com ${NC}"
    echo ""
}

# 7. Main Execution
main() {
    install_deps
    setup_python_env
    
    banner
    printf "Press ${GREEN}Enter${NC} To Continue..."
    read -r _
    
    banner
    
    if [[ -f "$SCRIPT_DIR/shortner.py" ]]; then
        # Run python inside the virtual environment
        python3 "$SCRIPT_DIR/shortner.py"
    else
        echo -e "${RED}[!] Error: 'shortner.py' not found.${NC}"
        exit 1
    fi
}

main