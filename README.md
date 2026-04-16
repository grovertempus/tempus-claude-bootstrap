# Tempus Claude Code Setup

This is the one-click installer that gets your Mac set up with Claude Code and the Tempus team's shared AI workflow.

## What you're installing

- **Claude Code** - Anthropic's AI assistant that runs in your Terminal
- **The Tempus plugin** - Grover's workflow setup: research-first sequencing, guardrails, plain-language defaults, and team-specific hooks

## Before you start

You'll need:
1. A Mac (this does not work on Windows or Linux yet)
2. A free [GitHub account](https://github.com/join) - you can make one during setup if you don't have one
3. Open an access request: [Request access here](https://github.com/grovertempus/tempus-claude-bootstrap/issues/new?template=access-request.md). Grover will add you as a collaborator, usually within a business day.

Once Grover has added you, run the one-line command below.

## Install

Open **Terminal** (press `Command + Space`, type `Terminal`, press Enter) and paste this:

```bash
curl -fsSL -o /tmp/tempus-setup.sh https://raw.githubusercontent.com/grovertempus/tempus-claude-bootstrap/main/install.sh && bash /tmp/tempus-setup.sh
```

Downloads the installer first, then runs it, so the installer has full access to your keyboard for the sign-in step.

The installer will walk you through everything. Total time: about 5-10 minutes.

## After install

Open a new Terminal window and type:

```
claude
```

That's it. Claude Code is ready.

## Questions?

Email Grover at grover.richardson@tempus.com
