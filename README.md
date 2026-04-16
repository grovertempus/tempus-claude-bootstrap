# Tempus Claude Code Setup

One-command installers for Claude Code on your Mac. Pick the one that fits your needs.

## Option 1: Deck Designer Only

For building Tempus presentations with Claude Code in VS Code. No GitHub account needed, no extra setup.

**What it installs:**
- VS Code
- Claude Code extension
- Deck Designer skill (/deck-designer)
- Tempus-Decks folder on your Desktop

**Run this in Terminal** (press Cmd+Space, type "Terminal", press Enter):

```bash
curl -fsSL -o /tmp/tempus-setup.sh https://raw.githubusercontent.com/grovertempus/tempus-claude-bootstrap/main/install-deck-designer.sh && bash /tmp/tempus-setup.sh
```

After it finishes, open VS Code, click the sparkle icon, sign in with **Anthropic Console**, and type `/deck-designer` to start.

---

## Option 2: Full Setup

For the full Tempus Claude Code toolkit with the marketing plugin, agents, hooks, and deck designer.

**What it installs:**
- Everything in Option 1, plus:
- Claude Code CLI (terminal access)
- GitHub CLI
- Tempus marketing plugin (agents, hooks, workflows)
- Auto-updates

**Before you start:**
1. You need a Mac
2. A free [GitHub account](https://github.com/join)
3. [Request access](https://github.com/grovertempus/tempus-claude-bootstrap/issues/new?template=access-request.md) to the Tempus tools repo. Grover will add you, usually within a business day.

### Get admin access first

You'll need temporary admin access to install Homebrew (a tool our setup needs). Tempus has an Admin by Request tool for this:

1. Click the **Admin by Request** icon in your Mac menu bar (top right corner, looks like a circle with a checkmark)
2. Click **Request administrator access**
3. Click **Yes** on the "Do you want to start an administrator session?" popup
4. Fill out the form:
   - **Email:** your Tempus email
   - **Reason:** `I need admin access to install Homebrew. It's required so that I can set up skills in Claude Code and automatically download skill files from Tempus GitHub.`
5. Click **OK** and wait for approval. You'll get an email when you're approved.

Once you have admin access, run the install command below.

**Run this in Terminal** once Grover has added you:

```bash
curl -fsSL -o /tmp/tempus-setup.sh https://raw.githubusercontent.com/grovertempus/tempus-claude-bootstrap/main/install.sh && bash /tmp/tempus-setup.sh
```

The installer walks you through everything. About 5-10 minutes.

After it finishes, open VS Code, click the sparkle icon, and sign in with **Anthropic Console**.

---

## Questions?

Email Grover at grover.richardson@tempus.com
