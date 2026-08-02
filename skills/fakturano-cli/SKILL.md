---
name: fakturano-cli
description: Use the Fakturano CLI for workspace discovery, invoice discovery, and timesheet automation. Trigger when a user asks Codex to use or explain the `fakturano` command, configure Fakturano CLI auth, list companies, projects, invoices, or time entries, filter invoices, create time entries, troubleshoot CLI errors, produce agent-friendly `--json` commands, or automate Fakturano workflows through API-key authentication.
---

# Fakturano CLI

## Overview

Use this skill to operate Fakturano through its installed `fakturano` CLI. Prefer the CLI over direct HTTP calls for company, project, invoice, and timesheet workflows unless the user explicitly asks for API-level work or the CLI is unavailable.

## Core Rules

- Prefer `--json` when another program, agent, or follow-up reasoning will consume the output.
- Keep diagnostics on stderr; do not mix commentary with JSON stdout when running commands.
- Never print, log, or persist raw API keys except when the user is intentionally configuring one.
- Discover IDs before mutating: run `fakturano companies list --json`, then `fakturano projects list --company <companyId> --json`.
- Use `fakturano invoices list --company <companyId> --json` for invoice discovery, totals, and invoice filtering.
- Use dates as `YYYY-MM-DD` and times as `HH:MM` in 24-hour format.
- For time entry creation, provide either `--hours` or `--start` plus `--end`, never both.
- Treat exit code `2` as usage/config/validation failure and exit code `1` as API/network failure.

## Quick Start

Check availability:

```bash
fakturano --help
```

If missing and the repo is available at `/Users/eraldohasanaj/Documents/mini-sheet`, install or refresh it:

```bash
cd /Users/eraldohasanaj/Documents/mini-sheet
make install-cli
hash -r
```

Configure after the user creates an API key in the app:

```bash
fakturano config set-url http://127.0.0.1:3000
fakturano config set-key msk_...
fakturano auth whoami --json
```

## Common Workflow

1. Verify identity:
   `fakturano auth whoami --json`
2. Discover companies:
   `fakturano companies list --json`
3. Discover projects:
   `fakturano projects list --company <companyId> --json`
4. List or filter invoices when invoice context is needed:
   `fakturano invoices list --company <companyId> --status issued --json`
5. Create time:
   `fakturano timesheet create --company <companyId> --project <projectId> --date YYYY-MM-DD --hours 2.5 --description "Work" --json`
6. Confirm time:
   `fakturano timesheet list --company <companyId> --from YYYY-MM-DD --to YYYY-MM-DD --json`

## Detailed Reference

Read [references/commands.md](references/commands.md) when you need exact command syntax, output shapes, config precedence, examples, troubleshooting, or workflow patterns.
