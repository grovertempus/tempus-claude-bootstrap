#!/usr/bin/env bash
# Tempus Claude Code Setup
# One-line install:
#   curl -fsSL -o /tmp/tempus-setup.sh https://raw.githubusercontent.com/grovertempus/tempus-claude-bootstrap/main/install.sh && bash /tmp/tempus-setup.sh

set -euo pipefail

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

# ─── Helpers ────────────────────────────────────────────────────────────────

print_banner() {
  echo ""
  echo "============================================="
  echo "       Tempus Claude Code Setup"
  echo "============================================="
  echo ""
  echo "This script sets up Claude Code on your Mac"
  echo "so you can use the same AI workflow as the"
  echo "rest of the Tempus marketing team."
  echo ""
  echo "Here's what's about to happen:"
  echo "  1. Make sure your Mac is compatible"
  echo "  2. Install Homebrew (a free Mac app installer)"
  echo "  3. Install the GitHub CLI and Node.js"
  echo "  4. Install Claude Code (Anthropic's AI tool)"
  echo "  5. Sign in to GitHub to access team tools"
  echo "  6. Install the Tempus Claude plugin"
  echo ""
  echo "This takes about 5-10 minutes on a fresh Mac."
  echo "---------------------------------------------"
  echo ""
}

print_success() {
  echo ""
  echo "============================================="
  echo "   You're all set!"
  echo "============================================="
  echo ""
  echo "Everything is installed and ready to go."
  echo ""
  echo "To start using Claude Code:"
  echo ""
  echo "  1. Open a NEW Terminal window"
  echo "  2. Type:  claude"
  echo "  3. Press Enter"
  echo ""
  echo "That's it. Claude Code will be ready to use."
  echo ""
  echo "Questions? Email grover.richardson@tempus.com"
  echo "============================================="
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

# ─── Checks ─────────────────────────────────────────────────────────────────

check_macos() {
  if [[ "$(uname)" != "Darwin" ]]; then
    echo ""
    echo "Sorry - this installer only works on a Mac."
    echo "If you need help on a different computer, email"
    echo "grover.richardson@tempus.com."
    exit 1
  fi
}

# ─── Installers ─────────────────────────────────────────────────────────────

install_homebrew() {
  if command -v brew &>/dev/null; then
    echo "✓ Homebrew already installed"
    return 0
  fi

  echo "Installing Homebrew (this can take a few minutes)..."
  echo "(Homebrew is a free, trusted tool installer for Mac)"
  echo ""

  if ! /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
    die "Homebrew installation failed. Please try again."
  fi

  # Add brew to PATH for this session (Apple Silicon + Intel)
  if [[ -d "/opt/homebrew/bin" ]]; then
    export PATH="/opt/homebrew/bin:$PATH"
  elif [[ -d "/usr/local/bin" ]]; then
    export PATH="/usr/local/bin:$PATH"
  fi

  echo ""
  echo "✓ Homebrew installed"
}

install_gh() {
  if command -v gh &>/dev/null; then
    echo "✓ GitHub CLI ready"
    return 0
  fi

  echo "Installing the GitHub CLI..."
  if ! brew install gh >/dev/null 2>&1; then
    die "Could not install the GitHub CLI. Check your internet connection and try again."
  fi
  echo "✓ GitHub CLI ready"
}

install_node() {
  if command -v node &>/dev/null; then
    echo "✓ Node ready"
    return 0
  fi

  echo "Installing Node.js (required by Claude Code)..."
  if ! brew install node >/dev/null 2>&1; then
    die "Could not install Node.js. Check your internet connection and try again."
  fi
  echo "✓ Node ready"
}

install_claude() {
  if command -v claude &>/dev/null; then
    echo "✓ Claude Code ready"
    return 0
  fi

  echo "Installing Claude Code..."
  if ! npm install -g @anthropic-ai/claude-code >/dev/null 2>&1; then
    die "Could not install Claude Code. Check your internet connection and try again."
  fi
  echo "✓ Claude Code ready"
}

# ─── GitHub Auth ─────────────────────────────────────────────────────────────

setup_github_auth() {
  if gh auth status &>/dev/null; then
    echo "✓ GitHub account connected"
    return 0
  fi

  echo ""
  echo "---------------------------------------------"
  echo "Next: Connect your GitHub account"
  echo ""
  echo "We need to connect to GitHub so we can pull"
  echo "the Tempus team tools into Claude Code."
  echo ""
  echo "We're going to open your browser so you can"
  echo "sign in to GitHub. This is a free account  - "
  echo "if you don't have one, you can create it on"
  echo "the page that opens."
  echo "---------------------------------------------"
  echo ""

  if ! gh auth login --web --hostname github.com --git-protocol https; then
    die "GitHub sign-in did not complete. Try running this installer again."
  fi

  echo "✓ GitHub account connected"
}

# ─── Repo Access ─────────────────────────────────────────────────────────────

verify_repo_access() {
  echo ""
  echo "Checking your access to Tempus team tools..."

  if ! gh repo view grovertempus/tempus-claude &>/dev/null; then
    echo ""
    echo "---------------------------------------------"
    echo "Access not set up yet!"
    echo ""
    echo "You don't have access to grovertempus/tempus-claude yet."
    echo ""
    echo "Request access here:"
    echo "  https://github.com/grovertempus/tempus-claude-bootstrap/issues/new?template=access-request.md"
    echo ""
    echo "Once Grover adds you, re-run this installer."
    echo "---------------------------------------------"
    echo ""
    die "You don't have access to grovertempus/tempus-claude yet. Request access at https://github.com/grovertempus/tempus-claude-bootstrap/issues/new?template=access-request.md and re-run this installer once Grover adds you."
  fi

  echo "✓ Access to Tempus team tools confirmed"
}

# ─── Backup ──────────────────────────────────────────────────────────────────

backup_existing_setup() {
  if [[ ! -d "$HOME/.claude" ]]; then
    return 0
  fi

  BACKUP_DIR="$HOME/.claude-backup-$(date +%s)"
  echo ""
  echo "Backing up your existing Claude setup..."
  rsync -a --exclude="plugins/" "$HOME/.claude/" "$BACKUP_DIR/" 2>/dev/null \
    || cp -R "$HOME/.claude" "$BACKUP_DIR"
  echo "✓ Backup saved to: $BACKUP_DIR"
  echo "  (This is a safety copy — it won't affect anything.)"
}

# ─── Plugin Install ──────────────────────────────────────────────────────────

install_plugin() {
  echo ""
  echo "Adding the Tempus plugin marketplace..."

  claude plugin marketplace add grovertempus/tempus-claude 2>/dev/null || true
  if ! claude plugin marketplace update tempus-claude 2>/dev/null; then
    die "Could not refresh the Tempus plugin marketplace."
  fi
  echo "✓ Tempus marketplace ready"

  # Clean up any previous installation to prevent duplicate registrations
  claude plugin uninstall tempus-marketing@tempus-claude 2>/dev/null || true

  echo "Installing the Tempus Claude plugin..."

  # ─── Collect pre-install diagnostic context ────────────────────────────────
  DIAG_LOG="/tmp/tempus-plugin-install.log"
  {
    echo "=== Tempus Plugin Install Diagnostics ==="
    echo "Date: $(date -u)"
    echo "macOS: $(sw_vers -productVersion 2>/dev/null || echo unknown)"
    echo "HOME=$HOME"
    echo "USER=$USER"
    echo "PATH=$PATH"
    echo ""
    echo "=== claude --version ==="
    claude --version 2>&1 || echo "(claude --version failed)"
    echo ""
    echo "=== claude plugin list ==="
    claude plugin list 2>&1 || echo "(claude plugin list failed)"
    echo ""
    echo "=== claude plugin marketplace list ==="
    claude plugin marketplace list 2>&1 || echo "(claude plugin marketplace list failed)"
    echo ""
    echo "=== ~/.claude (top-level) ==="
    ls -la "$HOME/.claude" 2>&1 || echo "(~/.claude not found)"
    echo ""
    echo "=== ~/.claude/plugins ==="
    ls -la "$HOME/.claude/plugins" 2>&1 || echo "(~/.claude/plugins not found)"
    echo ""
    echo "=== ~/.claude/marketplaces ==="
    ls -la "$HOME/.claude/marketplaces" 2>&1 || echo "(~/.claude/marketplaces not found)"
    echo ""
    echo "=== ~/.claude/settings.json ==="
    cat "$HOME/.claude/settings.json" 2>&1 || echo "(settings.json not found)"
    echo ""
    echo "=== plugin install: claude plugin install tempus-marketing@tempus-claude ==="
  } > "$DIAG_LOG" 2>&1

  # ─── Run plugin install, capturing full stdout+stderr ──────────────────────
  # Note: @tempus-claude is the marketplace name - this suffix is required and must not be removed
  INSTALL_EXIT=0
  INSTALL_OUT=$(claude plugin install tempus-marketing@tempus-claude 2>&1) || INSTALL_EXIT=$?
  printf '%s\nExit code: %s\n' "$INSTALL_OUT" "$INSTALL_EXIT" >> "$DIAG_LOG"

  if [ "$INSTALL_EXIT" -eq 0 ]; then
    echo "✓ Tempus Claude plugin installed"

    # Verify plugin is properly registered
    if ! claude plugin list 2>/dev/null | grep -q "tempus-marketing.*enabled"; then
      echo ""
      echo "Warning: Plugin installed but may not be active."
      echo "Try running: claude plugin install tempus-marketing@tempus-claude"
      echo "If that doesn't work, email grover.richardson@tempus.com"
    fi

    return 0
  fi

  # ─── Install failed — upload diagnostics as a public GitHub Gist ───────────
  echo ""
  echo "Collecting diagnostics for remote review..."

  GIST_URL=""
  if command -v gh &>/dev/null && gh auth status &>/dev/null 2>&1; then
    GIST_URL=$(gh gist create --public \
      --filename "tempus-install-diag.log" \
      "$DIAG_LOG" 2>/dev/null | tail -1) || true
  fi

  if [ -n "$GIST_URL" ]; then
    echo ""
    echo "============================================="
    echo "  Diagnostic log ready for Grover"
    echo "============================================="
    echo ""
    echo "  $GIST_URL"
    echo ""
    echo "  Send this URL to: grover.richardson@tempus.com"
    echo "  He can diagnose and fix the issue remotely."
    echo "============================================="
    echo ""
    die "Could not install the Tempus Claude plugin. Send the URL above to Grover."
  else
    die "Could not install the Tempus Claude plugin."
  fi
}

# ─── CLAUDE.md ───────────────────────────────────────────────────────────────

setup_claude_md() {
  PLUGIN_CLAUDE_MD="$HOME/.claude/plugins/tempus-claude/tempus-marketing/CLAUDE.md"
  DEST_CLAUDE_MD="$HOME/.claude/CLAUDE.md"
  START_MARKER="<!-- TEMPUS-PLUGIN-START -->"
  END_MARKER="<!-- TEMPUS-PLUGIN-END -->"

  if [[ ! -f "$PLUGIN_CLAUDE_MD" ]]; then
    echo ""
    echo "Note: Plugin instructions not found yet - skipping"
    echo "that step. This is normal on a first install."
    return 0
  fi

  PLUGIN_CONTENT="$(cat "$PLUGIN_CLAUDE_MD")"

  # Case 1: No existing CLAUDE.md - create fresh with markers
  if [[ ! -f "$DEST_CLAUDE_MD" ]]; then
    {
      echo "$START_MARKER"
      printf '%s\n' "$PLUGIN_CONTENT"
      echo "$END_MARKER"
    } > "$DEST_CLAUDE_MD"
    echo "✓ Instructions file created"
    return 0
  fi

  # Case 2: Markers already exist - update only the plugin section (idempotent re-run)
  if grep -q "$START_MARKER" "$DEST_CLAUDE_MD"; then
    # Extract everything before the start marker and after the end marker
    BEFORE_MARKER="$(awk "/$START_MARKER/{exit} {print}" "$DEST_CLAUDE_MD")"
    AFTER_MARKER="$(awk "found && /$END_MARKER/{found=0} found{print} /$END_MARKER/{found=1}" "$DEST_CLAUDE_MD")"
    {
      [[ -n "$BEFORE_MARKER" ]] && printf '%s\n' "$BEFORE_MARKER"
      echo "$START_MARKER"
      printf '%s\n' "$PLUGIN_CONTENT"
      echo "$END_MARKER"
      if [[ -n "$AFTER_MARKER" ]]; then
        printf '\n%s\n' "$AFTER_MARKER"
      fi
    } > "$DEST_CLAUDE_MD"
    echo "✓ Instructions updated"
    return 0
  fi

  # Case 3: Existing CLAUDE.md without markers - prepend plugin content (full backup already done)
  echo ""
  echo "Note: You already have a personal instructions file."
  echo "It's been preserved in your backup from the start of this install."

  EXISTING_CONTENT="$(cat "$DEST_CLAUDE_MD")"
  {
    echo "$START_MARKER"
    printf '%s\n' "$PLUGIN_CONTENT"
    echo "$END_MARKER"
    if [[ -n "$EXISTING_CONTENT" ]]; then
      echo ""
      echo "# Your Custom Instructions"
      echo "$EXISTING_CONTENT"
    fi
  } > "$DEST_CLAUDE_MD"
  echo "✓ Instructions merged — your custom settings are preserved below"
}

# ─── Auto-Update ─────────────────────────────────────────────────────────────

setup_autoupdate() {
  ZSHRC="$HOME/.zshrc"

  if grep -q "FORCE_AUTOUPDATE_PLUGINS" "$ZSHRC" 2>/dev/null; then
    echo "✓ Auto-update already configured"
    return 0
  fi

  {
    echo ""
    echo "# Tempus Claude Code - keep plugins auto-updated"
    echo "export FORCE_AUTOUPDATE_PLUGINS=1"
  } >> "$ZSHRC"

  echo "✓ Auto-update configured"
  echo ""
  echo "  Note: To activate this, open a new Terminal"
  echo "  window before using Claude Code."
}

# ─── Main ────────────────────────────────────────────────────────────────────

print_banner
check_macos
install_homebrew
install_gh
install_node
install_claude
setup_github_auth
verify_repo_access
backup_existing_setup
install_plugin
setup_claude_md
setup_autoupdate
print_success
