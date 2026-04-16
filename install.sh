#!/usr/bin/env bash
# Tempus Deck Designer Setup
# One-line install:
#   curl -fsSL -o /tmp/tempus-setup.sh https://raw.githubusercontent.com/grovertempus/tempus-claude-bootstrap/main/install.sh && bash /tmp/tempus-setup.sh

set -euo pipefail

# ─── Pipe Detection ──────────────────────────────────────────────────────────

if [ ! -t 0 ]; then
  echo ""
  echo "ERROR: This installer needs your keyboard for sign-in."
  echo ""
  echo "You ran it via a pipe, which blocks keyboard input. Instead, run:"
  echo ""
  echo "  curl -fsSL -o /tmp/tempus-setup.sh https://raw.githubusercontent.com/grovertempus/tempus-claude-bootstrap/main/install.sh && bash /tmp/tempus-setup.sh"
  echo ""
  exit 1
fi

# ─── Global Variables ────────────────────────────────────────────────────────

CODE_CLI="code"

# ─── Helpers ─────────────────────────────────────────────────────────────────

print_banner() {
  echo ""
  echo "============================================="
  echo "       Tempus Deck Designer Setup"
  echo "============================================="
  echo ""
  echo "This script sets up everything you need to"
  echo "build Tempus presentations using Claude Code"
  echo "in VS Code."
  echo ""
  echo "Here's what's about to happen:"
  echo "  1. Check Mac compatibility"
  echo "  2. Install VS Code"
  echo "  3. Install Claude Code extension"
  echo "  4. Set up your Decks folder"
  echo "  5. Download the Deck Designer skill"
  echo ""
  echo "This takes about 5 minutes."
  echo "---------------------------------------------"
  echo ""
}

print_success() {
  echo ""
  echo "============================================"
  echo "   You're almost there!"
  echo "============================================"
  echo ""
  echo "Everything is installed. Now just sign in:"
  echo ""
  echo "  1. Open VS Code"
  echo "  2. Click the sparkle icon (✦) in the left sidebar"
  echo "  3. When asked how to sign in, select:"
  echo "     \"Anthropic Console\" (API usage billing)"
  echo ""
  echo "     Do NOT select a personal Claude account."
  echo "     Tempus uses the Console for billing."
  echo ""
  echo "  4. Click \"Authorize\" in the browser window"
  echo "  5. Close the browser tab and go back to VS Code"
  echo ""
  echo "After signing in, follow the Deck Designer SOP"
  echo "starting from \"Install the Skill.\""
  echo ""
  echo "Questions? Email grover.richardson@tempus.com"
  echo "============================================"
  echo ""
}

die() {
  echo ""
  echo "Something went wrong: $1"
  echo ""
  echo "Please take a screenshot of this screen and"
  echo "email it to grover.richardson@tempus.com."
  echo ""
  exit 1
}

# ─── Checks ──────────────────────────────────────────────────────────────────

check_macos() {
  if [[ "$(uname)" != "Darwin" ]]; then
    echo ""
    echo "Sorry - this installer only works on a Mac."
    echo "If you need help on a different computer, email"
    echo "grover.richardson@tempus.com."
    exit 1
  fi
}

# ─── VS Code ─────────────────────────────────────────────────────────────────

install_vscode() {
  if [[ -d "/Applications/Visual Studio Code.app" ]]; then
    echo "✓ VS Code already installed"
  else
    echo "Downloading VS Code..."
    curl -fsSL -o /tmp/VSCode-universal.zip \
      "https://update.code.visualstudio.com/latest/darwin-universal/stable" \
      || die "Could not download VS Code. Check your internet connection and try again."

    echo "Installing VS Code..."
    unzip -q /tmp/VSCode-universal.zip -d /tmp/ \
      || die "Could not unzip VS Code. Try again."

    mv "/tmp/Visual Studio Code.app" /Applications/ \
      || die "Could not move VS Code to Applications. You may need to do this step manually."

    rm -f /tmp/VSCode-universal.zip

    echo "✓ VS Code installed"
  fi

  # Resolve the `code` CLI
  if command -v code &>/dev/null; then
    CODE_CLI="code"
  elif [[ -x "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" ]]; then
    CODE_CLI="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
  else
    die "Could not find the VS Code command-line tool. Try opening VS Code and running 'Shell Command: Install code command in PATH' from the command palette."
  fi
}

# ─── Claude Code Extension ───────────────────────────────────────────────────

install_claude_ext() {
  if "$CODE_CLI" --list-extensions 2>/dev/null | grep -q "anthropic.claude-code"; then
    echo "✓ Claude Code extension already installed"
    return 0
  fi

  echo "Installing the Claude Code extension..."
  "$CODE_CLI" --install-extension anthropic.claude-code --force \
    || die "Could not install the Claude Code extension. Make sure VS Code is not open and try again."

  echo "✓ Claude Code extension installed"
}

# ─── Decks Folder ────────────────────────────────────────────────────────────

setup_decks_folder() {
  if [[ ! -d "$HOME/Desktop/Tempus-Decks" ]]; then
    mkdir -p "$HOME/Desktop/Tempus-Decks"
  fi
  echo "✓ Tempus-Decks folder ready on your Desktop"
}

# ─── Deck Designer Skill ─────────────────────────────────────────────────────

install_skill() {
  SKILL_DIR="$HOME/.claude/skills/deck-designer"

  if [[ -f "$SKILL_DIR/SKILL.md" ]]; then
    echo "✓ Deck Designer skill already installed"
    return 0
  fi

  mkdir -p "$SKILL_DIR"

  curl -fsSL \
    -o "$SKILL_DIR/SKILL.md" \
    "https://raw.githubusercontent.com/grovertempus/tempus-claude-bootstrap/main/SKILL.md" \
    || die "Could not download the Deck Designer skill file. Check your internet connection and try again."

  echo "✓ Deck Designer skill installed (/deck-designer)"
}

# ─── Main ────────────────────────────────────────────────────────────────────

print_banner
check_macos
install_vscode
install_claude_ext
setup_decks_folder
install_skill
print_success
