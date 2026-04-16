# About the Tempus Claude Code setup

Think of Claude like a thoughtful new hire. Capable, eager, but works best with structure. The full setup gives Claude that structure so it behaves consistently, stays focused, and doesn't go off and do something you didn't ask for.

## Personality and tone

- Talks to you like a person, not a textbook. Plain English, no jargon, no lectures.
- Matches your energy. If you're casual, it's casual. If you're in a rush, it's brief.
- No corporate fluff. No walls of text. No bullet-point dumps when a sentence will do.
- Asks you one question at a time when something is unclear, instead of firing off five at once.

## How it approaches work

- **Research before it acts.** If you ask for anything non-trivial, Claude spins up a small "research team" to investigate before writing code or making changes. It doesn't guess.
- **Plan before it builds.** Before any real work happens, Claude writes up a plan and shows it to you. You approve it, then it starts. No surprises.
- **Verifies before it says things are true.** If Claude isn't sure about something, it checks instead of guessing.

## What keeps it honest

- **Guardrails.** Background checks catch Claude if it tries to skip the plan step, edit files it shouldn't, or do risky things like force-push code. You don't see these running, they just work.
- **No destructive actions without permission.** Anything that could cause damage (deleting files, pushing code, sending a message) requires you to say yes first.
- **Agent handoff rules.** When Claude passes work to a teammate agent, it has to include what was done, what worked, what didn't, and any open questions. Nothing gets lost in translation.

## What it remembers

Within a single conversation, Claude remembers everything you've said earlier. It scans back through the conversation to pull context instead of asking you to repeat yourself.

## How it tackles bigger jobs

The setup includes a crew of specialized agents Claude can call on:

- **Research-mapper:** investigates a question before work starts
- **Plan-executor:** carries out approved plans step by step
- **Fix-cycle:** fixes issues, simplifies, and verifies everything works
- **Debug-logger / debug-specialist:** finds and solves bugs with evidence
- **Reviewer:** double-checks work before it ships
- **Solution-architect:** offers strategic options when you're stuck
- **Project-planning-architect:** maps out complex projects
- **Checklist-manager:** keeps launch checklists up to date

## Skills built in

- **Deck Designer** — builds Tempus presentations
- **Frontend Design** — for building web pages or UI
- Plus workflow skills that keep Claude following the research → plan → verify pattern

## Questions?

Email Grover at grover.richardson@tempus.com
