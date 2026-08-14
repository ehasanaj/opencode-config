---
name: fakturano-cli
description: Use the Fakturano CLI for workspace discovery, CRM management, invoice discovery, vacation self-service and administration, WorkOS employee synchronization, and timesheet automation. Trigger when a user asks to use or explain the `fakturano` command, configure CLI auth, list companies, projects, CRM records, invoices, vacations, leave balances, calendars, locations, public holidays, policies, overrides, or time entries, create or update those supported records, preview or book vacation, synchronize vacation employees, troubleshoot CLI errors, produce agent-friendly `--json` commands, or automate Fakturano workflows through API-key authentication.
---

# Fakturano CLI

## Overview

Use this skill to operate Fakturano through its installed `fakturano` CLI. Prefer the CLI over direct HTTP calls for company, project, CRM, invoice, vacation, and timesheet workflows unless the user explicitly asks for API-level work or the CLI is unavailable.

## Core Rules

- Prefer `--json` when another program, agent, or follow-up reasoning will consume the output.
- Keep diagnostics on stderr; do not mix commentary with JSON stdout when running commands.
- Never print, log, or persist raw API keys except when the user is intentionally configuring one.
- Discover IDs before mutating: run `fakturano companies list --json`; use `projects list` for project IDs, `crm list` for offering/lead IDs, and `crm members list` for responsible user IDs.
- CRM mutations require an admin membership. Regular members can use CRM list commands but receive HTTP 403 for create/update commands.
- Lead stages are exactly `new`, `contacted`, `active_communication`, `cold`, `won`, and `lost`.
- Treat message direction from the company perspective: `outbound` means sent by us and `inbound` means received from them.
- Read lead messages before recording new communication. Every member may read histories; only admins may create messages.
- Supply `--occurred-at` as an ISO 8601 date-time with `Z` or an explicit timezone offset.
- Use `fakturano invoices list --company <companyId> --json` for invoice discovery, totals, and invoice filtering.
- Before vacation mutations, discover state with `vacations list`, `vacations locations list`, `vacations policies list`, and, for admins, `vacations balances list`.
- Preview a personal booking with `vacations preview` before `vacations create`; members, including admins, may mutate only their own vacation records.
- Treat vacation configuration mutations, location assignments, balance listing, and employee synchronization as admin-only. Members may read the shared calendar and visible locations, holidays, policies, and their own override.
- Run `vacations employees sync` without `--apply true` first. It previews WorkOS changes; only apply after reviewing the added, updated, and departed employees.
- Use business dates as `YYYY-MM-DD`; vacation human output renders `dd.MM.yyyy`. Use times as `HH:MM` in 24-hour format.
- For time entry creation, provide either `--hours` or `--start` plus `--end`, never both.
- Treat exit code `2` as usage/config/validation failure and exit code `1` as API/network failure.

## Quick Start

Check availability:

```bash
fakturano --help
```

If missing and the repo is available at `/Users/eraldohasanaj/Development/mini-sheet`, install or refresh it:

```bash
cd /Users/eraldohasanaj/Development/mini-sheet
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
4. Discover CRM records and valid lead owners when CRM context is needed:
   `fakturano crm list --company <companyId> --json`
   `fakturano crm members list --company <companyId> --json`
   Read a selected lead's communication with `fakturano crm leads messages list --company <companyId> --lead <leadId> --json`.
5. Inspect or manage leave when vacation context is needed:
   `fakturano vacations summary --company <companyId> --json`
   `fakturano vacations calendar --company <companyId> --year YYYY --month M --json`
   Preview before booking with `fakturano vacations preview --company <companyId> --start YYYY-MM-DD --end YYYY-MM-DD --json`.
6. List or filter invoices when invoice context is needed:
   `fakturano invoices list --company <companyId> --status issued --json`
7. Create time:
   `fakturano timesheet create --company <companyId> --project <projectId> --date YYYY-MM-DD --hours 2.5 --description "Work" --json`
8. Confirm time:
   `fakturano timesheet list --company <companyId> --from YYYY-MM-DD --to YYYY-MM-DD --json`

## Detailed Reference

Read [references/commands.md](references/commands.md) when you need exact command syntax, output shapes, config precedence, examples, troubleshooting, or workflow patterns.
