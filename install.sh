#!/usr/bin/env bash
# Tempus Claude Code Setup
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
  echo "       Tempus Claude Code Setup"
  echo "============================================="
  echo ""
  echo "This script sets up Claude Code on your Mac"
  echo "with the full Tempus marketing toolkit."
  echo ""
  echo "Here's what's about to happen:"
  echo "  1. Check Mac compatibility"
  echo "  2. Install VS Code"
  echo "  3. Install Claude Code extension"
  echo "  4. Install Claude Code CLI"
  echo "  5. Install GitHub CLI"
  echo "  6. Connect your GitHub account"
  echo "  7. Install the Tempus plugin"
  echo "  8. Sync personal hooks and scripts from plugin"
  echo "  9. Set up Deck Designer"
  echo ""
  echo "This takes about 5-10 minutes."
  echo "---------------------------------------------"
  echo ""
}

print_success() {
  echo ""
  echo "============================================="
  echo "   You're all set!"
  echo "============================================="
  echo ""
  echo "Everything is installed."
  echo ""
  echo "To start: Open VS Code, click the sparkle icon,"
  echo "sign in with Anthropic Console (not personal account)"
  echo ""
  echo "Once signed in, type /deck-designer to build"
  echo "a presentation."
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
  # Check if VS Code is already installed anywhere
  if [[ -d "/Applications/Visual Studio Code.app" ]]; then
    echo "✓ VS Code already installed"
    VSCODE_APP="/Applications/Visual Studio Code.app"
  elif [[ -d "$HOME/Applications/Visual Studio Code.app" ]]; then
    echo "✓ VS Code already installed"
    VSCODE_APP="$HOME/Applications/Visual Studio Code.app"
  else
    echo "Downloading VS Code..."
    curl -fsSL -o /tmp/VSCode-universal.zip \
      "https://update.code.visualstudio.com/latest/darwin-universal/stable" \
      || die "Could not download VS Code. Check your internet connection and try again."

    echo "Installing VS Code..."
    rm -rf "/tmp/Visual Studio Code.app"
    unzip -oq /tmp/VSCode-universal.zip -d /tmp/ \
      || die "Could not unzip VS Code. Try again."

    # Remove macOS quarantine flag so Gatekeeper doesn't block it
    xattr -cr "/tmp/Visual Studio Code.app" 2>/dev/null

    # Try /Applications first, fall back to ~/Applications
    if mv "/tmp/Visual Studio Code.app" /Applications/ 2>/dev/null; then
      VSCODE_APP="/Applications/Visual Studio Code.app"
    else
      echo "  (Can't write to /Applications — using ~/Applications instead)"
      mkdir -p "$HOME/Applications"
      mv "/tmp/Visual Studio Code.app" "$HOME/Applications/" \
        || die "Could not install VS Code. Try dragging it to your Applications folder manually."
      VSCODE_APP="$HOME/Applications/Visual Studio Code.app"
    fi

    rm -f /tmp/VSCode-universal.zip
    echo "✓ VS Code installed"
  fi

  # Resolve the code CLI
  if command -v code &>/dev/null; then
    CODE_CLI="code"
  elif [[ -x "$VSCODE_APP/Contents/Resources/app/bin/code" ]]; then
    CODE_CLI="$VSCODE_APP/Contents/Resources/app/bin/code"
  else
    die "Could not find the VS Code command-line tool. Try opening VS Code first, then run this installer again."
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

# ─── Homebrew ────────────────────────────────────────────────────────────────

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

# ─── GitHub CLI ──────────────────────────────────────────────────────────────

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

# ─── Claude Code CLI ─────────────────────────────────────────────────────────

install_claude_cli() {
  if command -v claude &>/dev/null; then
    echo "✓ Claude Code CLI ready"
    return 0
  fi

  echo "Installing Claude Code CLI..."
  curl -fsSL https://claude.ai/install.sh | bash

  # Source the updated PATH
  export PATH="$HOME/.claude/bin:$PATH"

  if ! command -v claude &>/dev/null; then
    die "Claude Code CLI installation failed."
  fi

  echo "✓ Claude Code CLI ready"
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
    echo "You need to be added to the Tempus tools repo"
    echo "before the installer can continue."
    echo ""
    echo "To find your GitHub username, run this command:"
    echo "  gh api user --jq .login"
    echo ""
    echo "Then send it to: grover.richardson@tempus.com"
    echo "and re-run this installer once Grover adds you."
    echo "---------------------------------------------"
    echo ""
    die "You don't have access to grovertempus/tempus-claude yet. Email grover.richardson@tempus.com with your GitHub username so you can be added, then re-run this installer."
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

  # If a prior install registered the marketplace via SSH, remove it so the HTTPS re-add takes effect
  if claude plugin marketplace list 2>/dev/null | grep -q "git@github.com:grovertempus/tempus-claude"; then
    claude plugin marketplace remove tempus-claude 2>/dev/null || true
  fi

  # Use explicit HTTPS URL so users without GitHub SSH keys can still clone the private marketplace
  claude plugin marketplace add https://github.com/grovertempus/tempus-claude.git 2>/dev/null || true
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

# ─── Sync Infrastructure ─────────────────────────────────────────────────────

sync_infrastructure_from_plugin() {
  echo ""
  echo "✓ Syncing infrastructure hooks and scripts..."

  # Locate the most recently modified version directory in the plugin cache
  local PLUGIN_ROOT
  PLUGIN_ROOT="$(ls -td "$HOME/.claude/plugins/cache/tempus-claude/tempus-marketing/"*/ 2>/dev/null | head -1 || true)"

  if [[ -z "$PLUGIN_ROOT" ]] || [[ ! -d "$PLUGIN_ROOT" ]]; then
    echo "  Warning: Plugin cache not found — skipping infrastructure sync."
    echo "  Re-run this installer after the plugin installs to sync hooks."
    return 0
  fi

  # Filenames that must never be overwritten (personal-only hooks)
  local -a ALLOWLIST=(
    "block_screenshot.sh"
  )

  _in_allowlist() {
    local fname="$1"
    local entry
    for entry in "${ALLOWLIST[@]}"; do
      [[ "$fname" == "$entry" ]] && return 0
    done
    return 1
  }

  # ── Sync hooks ──────────────────────────────────────────────────────────────
  mkdir -p "$HOME/.claude/hooks"
  local hooks_copied=0

  for src in "$PLUGIN_ROOT/hooks/"*.sh "$PLUGIN_ROOT/hooks/"*.py; do
    [[ -f "$src" ]] || continue
    local fname="${src##*/}"

    # Skip hooks.json (not a .sh or .py, so won't match), skip allowlisted names
    if _in_allowlist "$fname"; then
      continue
    fi

    # Rewrite ${CLAUDE_PLUGIN_ROOT} → absolute $HOME/.claude
    local dest="$HOME/.claude/hooks/$fname"
    sed "s|\${CLAUDE_PLUGIN_ROOT}|$HOME/.claude|g" "$src" > "$dest"
    chmod +x "$dest"
    hooks_copied=$((hooks_copied + 1))
  done

  echo "  ✓ $hooks_copied hooks copied to ~/.claude/hooks/"

  # ── Sync scripts ─────────────────────────────────────────────────────────────
  mkdir -p "$HOME/.claude/scripts"
  local scripts_copied=0

  for src in "$PLUGIN_ROOT/scripts/"*.cjs "$PLUGIN_ROOT/scripts/"*.sh; do
    [[ -f "$src" ]] || continue
    local fname="${src##*/}"
    local dest="$HOME/.claude/scripts/$fname"
    sed "s|\${CLAUDE_PLUGIN_ROOT}|$HOME/.claude|g" "$src" > "$dest"
    chmod +x "$dest"
    scripts_copied=$((scripts_copied + 1))
  done

  echo "  ✓ $scripts_copied scripts copied to ~/.claude/scripts/"

  # ── Merge settings.json hook wirings ────────────────────────────────────────

  # Ensure jq is available
  if ! command -v jq &>/dev/null; then
    echo ""
    echo "  Installing jq (needed for settings.json hook wiring)..."
    if ! brew install jq >/dev/null 2>&1; then
      echo ""
      echo "  Warning: jq could not be installed. Please add the following"
      echo "  hook wirings to ~/.claude/settings.json manually:"
      echo ""
      echo "  UserPromptSubmit: $HOME/.claude/hooks/tldr_reminder.sh (timeout 5)"
      echo "  Stop: /opt/homebrew/bin/node $HOME/.claude/scripts/supermemory-save.cjs (timeout 30)"
      echo "  Stop: /usr/bin/env python3 $HOME/.claude/hooks/tldr_length_check.py (timeout 5)"
      echo "  Stop: /usr/bin/env python3 $HOME/.claude/hooks/post_plan_silence_check.py (timeout 5)"
      return 0
    fi
  fi

  local SETTINGS="$HOME/.claude/settings.json"

  # Create minimal settings.json if it doesn't exist
  if [[ ! -f "$SETTINGS" ]]; then
    cat > "$SETTINGS" <<SETTINGS_EOF
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$HOME/.claude/hooks/tldr_reminder.sh",
            "timeout": 5
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "/opt/homebrew/bin/node $HOME/.claude/scripts/supermemory-save.cjs",
            "timeout": 30
          },
          {
            "type": "command",
            "command": "/usr/bin/env python3 $HOME/.claude/hooks/tldr_length_check.py",
            "timeout": 5
          },
          {
            "type": "command",
            "command": "/usr/bin/env python3 $HOME/.claude/hooks/post_plan_silence_check.py",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
SETTINGS_EOF
    echo "  ✓ settings.json hook wirings created"
    return 0
  fi

  # settings.json exists — use jq to merge canonical wirings while preserving all other keys.
  #
  # Strategy: for UserPromptSubmit[0].hooks and Stop[0].hooks, remove any existing entries
  # whose command contains "$HOME/.claude/hooks/" or "$HOME/.claude/scripts/" (old managed
  # copies), then append the canonical entries. This is idempotent and safe.

  local HOME_ESC
  HOME_ESC="$(printf '%s' "$HOME" | sed 's/[\/&]/\\&/g')"

  # Build the canonical entries as JSON for injection
  local CANONICAL_UPS_ENTRY
  CANONICAL_UPS_ENTRY=$(jq -n \
    --arg cmd "$HOME/.claude/hooks/tldr_reminder.sh" \
    '{"type":"command","command":$cmd,"timeout":5}')

  local CANONICAL_STOP_ENTRY_1
  CANONICAL_STOP_ENTRY_1=$(jq -n \
    --arg cmd "/opt/homebrew/bin/node $HOME/.claude/scripts/supermemory-save.cjs" \
    '{"type":"command","command":$cmd,"timeout":30}')

  local CANONICAL_STOP_ENTRY_2
  CANONICAL_STOP_ENTRY_2=$(jq -n \
    --arg cmd "/usr/bin/env python3 $HOME/.claude/hooks/tldr_length_check.py" \
    '{"type":"command","command":$cmd,"timeout":5}')

  local CANONICAL_STOP_ENTRY_3
  CANONICAL_STOP_ENTRY_3=$(jq -n \
    --arg cmd "/usr/bin/env python3 $HOME/.claude/hooks/post_plan_silence_check.py" \
    '{"type":"command","command":$cmd,"timeout":5}')

  local TMPFILE
  TMPFILE="$(mktemp /tmp/tempus-settings-XXXXXX.json)"

  # jq script:
  # 1. Ensure .hooks exists
  # 2. Ensure .hooks.UserPromptSubmit is an array with at least one entry
  # 3. In UPS[0].hooks: remove old tempus-managed entries then append canonical one
  # 4. Ensure .hooks.Stop is an array with at least one entry
  # 5. In Stop[0].hooks: remove old tempus-managed entries then append the three canonical ones
  jq \
    --argjson ups_entry "$CANONICAL_UPS_ENTRY" \
    --argjson stop1 "$CANONICAL_STOP_ENTRY_1" \
    --argjson stop2 "$CANONICAL_STOP_ENTRY_2" \
    --argjson stop3 "$CANONICAL_STOP_ENTRY_3" \
    --arg home "$HOME" \
    '
    # Helper: does a command string belong to tempus-managed personal hooks/scripts?
    def is_tempus_managed($home):
      .command | (
        test($home + "/.claude/hooks/tldr_reminder.sh") or
        test($home + "/.claude/hooks/tldr_length_check.py") or
        test($home + "/.claude/hooks/post_plan_silence_check.py") or
        test($home + "/.claude/scripts/supermemory-save.cjs")
      );

    # Ensure .hooks exists
    .hooks //= {}

    # ── UserPromptSubmit ──────────────────────────────────────────────────────
    | .hooks.UserPromptSubmit //= [{}]
    | if (.hooks.UserPromptSubmit | length) == 0 then .hooks.UserPromptSubmit = [{}] else . end
    | .hooks.UserPromptSubmit[0].hooks //= []
    # Remove stale tempus-managed entries, then append canonical one
    | .hooks.UserPromptSubmit[0].hooks |= (
        [ .[] | select(is_tempus_managed($home) | not) ]
        + [$ups_entry]
      )

    # ── Stop ─────────────────────────────────────────────────────────────────
    | .hooks.Stop //= [{}]
    | if (.hooks.Stop | length) == 0 then .hooks.Stop = [{}] else . end
    | .hooks.Stop[0].hooks //= []
    # Remove stale tempus-managed entries, then append canonical three
    | .hooks.Stop[0].hooks |= (
        [ .[] | select(is_tempus_managed($home) | not) ]
        + [$stop1, $stop2, $stop3]
      )
    ' "$SETTINGS" > "$TMPFILE"

  if [[ $? -eq 0 ]] && [[ -s "$TMPFILE" ]]; then
    mv "$TMPFILE" "$SETTINGS"
    echo "  ✓ settings.json hook wirings updated"
  else
    rm -f "$TMPFILE"
    echo ""
    echo "  Warning: Could not safely merge settings.json hook wirings."
    echo "  Please add the following entries manually:"
    echo "    UserPromptSubmit: $HOME/.claude/hooks/tldr_reminder.sh (timeout 5)"
    echo "    Stop: /opt/homebrew/bin/node $HOME/.claude/scripts/supermemory-save.cjs (timeout 30)"
    echo "    Stop: /usr/bin/env python3 $HOME/.claude/hooks/tldr_length_check.py (timeout 5)"
    echo "    Stop: /usr/bin/env python3 $HOME/.claude/hooks/post_plan_silence_check.py (timeout 5)"
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

# ─── Decks Folder ────────────────────────────────────────────────────────────

setup_decks_folder() {
  local dest="$HOME/Desktop/Tempus-Decks"
  mkdir -p "$dest"

  # Find the most-recently-modified tempus-assets dir in the plugin cache
  local assets_src
  assets_src="$(ls -td "$HOME/.claude/plugins/cache/tempus-claude/tempus-marketing/"*/tempus-assets 2>/dev/null | head -1 || true)"

  if [[ -z "$assets_src" ]] || [[ ! -d "$assets_src" ]]; then
    echo "ℹ Tempus-Decks folder ready on your Desktop (templates will appear after first Claude launch)"
    return 0
  fi

  for src_file in "$assets_src"/*.pptx; do
    [[ -f "$src_file" ]] || continue
    local base="${src_file##*/}"
    local dst_file="$dest/$base"
    [[ -e "$dst_file" ]] && continue
    # LFS pointer stubs are ~130-byte text files; don't copy one in place of the real .pptx
    if head -c 100 "$src_file" 2>/dev/null | grep -q "git-lfs.github.com/spec/v1"; then
      echo "⚠ Template file is a Git LFS stub, skipping: $base"
      continue
    fi
    cp "$src_file" "$dst_file"
    echo "✓ Copied $base"
  done

  echo "✓ Tempus-Decks folder ready on your Desktop with templates"
}

# ─── Deck Designer Skill ─────────────────────────────────────────────────────

install_skill() {
  SKILL_DIR="$HOME/.claude/skills/deck-designer"

  mkdir -p "$SKILL_DIR"

  curl -fsSL \
    -o "$SKILL_DIR/SKILL.md" \
    "https://raw.githubusercontent.com/grovertempus/tempus-claude-bootstrap/main/SKILL.md" \
    || die "Could not download the Deck Designer skill file. Check your internet connection and try again."

  echo "✓ Deck Designer skill installed/updated (/deck-designer)"
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
install_vscode
install_claude_ext
install_homebrew
install_gh
install_claude_cli
setup_github_auth
verify_repo_access
backup_existing_setup
install_plugin
sync_infrastructure_from_plugin
setup_claude_md
setup_decks_folder
install_skill
setup_autoupdate
print_success
