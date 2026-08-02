# Fakturano CLI Command Reference

## Table Of Contents

- Installation and availability
- Authentication and config
- Global flags
- Commands
- JSON output patterns
- Workflows
- Troubleshooting

## Installation And Availability

The command name is `fakturano`.

Check whether it is installed:

```bash
fakturano --help
```

If the command is missing and the project repository is available:

```bash
cd /Users/eraldohasanaj/Documents/mini-sheet
make install-cli
hash -r
```

`make install-cli` builds the CLI and runs `npm link` from `cli/`, globally linking the `fakturano` binary. If direct execution is needed without global linking:

```bash
node /Users/eraldohasanaj/Documents/mini-sheet/cli/dist/index.js --help
```

## Authentication And Config

Fakturano CLI authenticates with a user-scoped API key created in the web app API keys page. API keys start with `msk_` and are shown only once.

Configuration file:

```text
${XDG_CONFIG_HOME:-~/.config}/fakturano/config.json
```

The config file stores:

```json
{
  "apiKey": "msk_...",
  "baseUrl": "http://127.0.0.1:3000"
}
```

Precedence, highest first:

1. CLI flags: `--api-key`, `--base-url`
2. Environment: `FAKTURANO_API_KEY`, `FAKTURANO_BASE_URL`
3. Legacy environment fallbacks: `MINI_SHEET_API_KEY`, `MINI_SHEET_BASE_URL`
4. Config file

Set config:

```bash
fakturano config set-url http://127.0.0.1:3000
fakturano config set-key msk_...
```

Inspect config safely:

```bash
fakturano config show
fakturano config path
```

`config show` masks the key as `msk_abcd...`; it must not print the raw key.

## Global Flags

Use these before or after the command name as supported by the CLI parser:

```bash
--json
--api-key <key>
--base-url <url>
--help
-h
```

Prefer `--json` for agent workflows. In JSON mode, stdout should contain exactly one JSON object. Errors and diagnostics go to stderr.

## Commands

### Help

```bash
fakturano --help
fakturano help
fakturano help timesheet
fakturano timesheet create --help
```

### Auth

```bash
fakturano auth whoami
fakturano auth whoami --json
```

JSON shape:

```json
{
  "user": {
    "id": "usr_...",
    "name": "Name",
    "email": "name@example.com"
  },
  "memberships": [
    {
      "companyId": "cmp_...",
      "role": "admin",
      "company": {
        "name": "Example GmbH"
      }
    }
  ]
}
```

### Companies

Companies are derived from `/api/me` memberships:

```bash
fakturano companies list
fakturano companies list --json
```

JSON shape:

```json
{
  "companies": [
    {
      "id": "cmp_...",
      "name": "Example GmbH",
      "role": "admin"
    }
  ]
}
```

### Projects

List active projects for a company:

```bash
fakturano projects list --company cmp_...
fakturano projects list --company cmp_... --json
```

JSON shape:

```json
{
  "projects": [
    {
      "id": "prj_...",
      "name": "Retainer",
      "clientId": "cli_...",
      "hourlyRate": 95,
      "invoiceLanguage": "en",
      "currency": "EUR",
      "active": true
    }
  ]
}
```

### Invoices List

List recent invoices for a company:

```bash
fakturano invoices list --company cmp_... --json
```

Filter by invoice issue date:

```bash
fakturano invoices list \
  --company cmp_... \
  --issue-from 2026-07-01 \
  --issue-to 2026-07-31 \
  --json
```

Filter by client, project, status, and result limit:

```bash
fakturano invoices list \
  --company cmp_... \
  --client cli_... \
  --project prj_... \
  --status issued \
  --limit 25 \
  --json
```

Filter reversal invoices or invoice text fields:

```bash
fakturano invoices list --company cmp_... --kind reversal --max-total 0 --json
fakturano invoices list --company cmp_... --number RE-2026 --notes retainer --json
```

Rules:

- `--company` is required.
- `--client` maps to the API `clientId` filter.
- `--project` maps to the API `projectId` filter.
- `--status` accepts `draft`, `issued`, or `reversed`.
- `--kind` accepts `standard` or `reversal`.
- `--number` and `--notes` are case-insensitive contains filters.
- `--issue-from` and `--issue-to` filter invoice issue dates and must use `YYYY-MM-DD`.
- `--service-from` and `--service-to` filter invoices whose service period overlaps the requested dates.
- `--language` accepts `en` or `de`.
- `--min-total` and `--max-total` filter invoice totals; negative values are valid for reversal invoices.
- `--limit` defaults to `200` and caps at `1000`.

JSON shape:

```json
{
  "invoices": [
    {
      "id": "inv_...",
      "number": "RE-2026-0001",
      "status": "issued",
      "invoiceKind": "standard",
      "issueDate": "2026-07-03",
      "serviceStart": "2026-07-01",
      "serviceEnd": "2026-07-31",
      "clientId": "cli_...",
      "projectIds": ["prj_..."],
      "total": 119,
      "currency": "EUR",
      "language": "en"
    }
  ],
  "totalAmount": 119
}
```

### Timesheet Create

Create by decimal hours:

```bash
fakturano timesheet create \
  --company cmp_... \
  --project prj_... \
  --date 2026-07-03 \
  --hours 2.5 \
  --description "Implementation" \
  --json
```

Create by start/end time:

```bash
fakturano timesheet create \
  --company cmp_... \
  --project prj_... \
  --date 2026-07-03 \
  --start 09:00 \
  --end 10:30 \
  --description "Planning" \
  --json
```

Mark non-billable:

```bash
fakturano timesheet create \
  --company cmp_... \
  --project prj_... \
  --date 2026-07-03 \
  --hours 1 \
  --no-billable \
  --json
```

Rules:

- `--company`, `--project`, and `--date` are required.
- `--hours` must be between `0.01` and `24`.
- `--start` and `--end` must use `HH:MM`.
- Use either `--hours` or `--start` plus `--end`, never both.
- Billable defaults to true unless `--no-billable` is passed.

JSON shape:

```json
{
  "entry": {
    "id": "time_...",
    "companyId": "cmp_...",
    "projectId": "prj_...",
    "userId": "usr_...",
    "entryDate": "2026-07-03",
    "startTime": "",
    "endTime": "",
    "hours": 2.5,
    "description": "Implementation",
    "billable": true,
    "invoicedInvoiceId": null,
    "createdAt": "2026-07-03T..."
  }
}
```

### Timesheet List

List recent entries:

```bash
fakturano timesheet list --company cmp_... --json
```

Filter by project and date range:

```bash
fakturano timesheet list \
  --company cmp_... \
  --project prj_... \
  --from 2026-07-01 \
  --to 2026-07-31 \
  --json
```

Filter by status:

```bash
fakturano timesheet list --company cmp_... --billable true --invoiced false --json
```

Filter by user and limit:

```bash
fakturano timesheet list --company cmp_... --user usr_... --limit 50 --json
```

Rules:

- `--company` is required.
- `--from` and `--to` must use `YYYY-MM-DD`; `--from` must be before or equal to `--to`.
- `--billable` and `--invoiced` accept only `true` or `false`.
- `--limit` defaults to `200` and caps at `1000`.

JSON shape:

```json
{
  "entries": [
    {
      "id": "time_...",
      "projectId": "prj_...",
      "userId": "usr_...",
      "entryDate": "2026-07-03",
      "hours": 2.5,
      "description": "Implementation",
      "billable": true,
      "invoicedInvoiceId": null
    }
  ],
  "totalHours": 2.5
}
```

## JSON Output Patterns

Use `--json` and parse stdout. Do not parse human tables.

Good:

```bash
fakturano companies list --json
fakturano projects list --company "$company_id" --json
fakturano invoices list --company "$company_id" --status issued --json
fakturano timesheet list --company "$company_id" --from 2026-07-01 --to 2026-07-31 --json
```

Bad:

```bash
fakturano companies list | grep ...
```

## Workflows

### Create A Time Entry By Project Name

1. Run `fakturano companies list --json`.
2. Select the company by name or ask the user if ambiguous.
3. Run `fakturano projects list --company <companyId> --json`.
4. Select an active project by name or ask the user if ambiguous.
5. Run `fakturano timesheet create ... --json`.
6. Report the created entry id, date, project id, and hours.

### Summarize Time For A Month

1. Discover or accept the company id.
2. Run `fakturano timesheet list --company <companyId> --from YYYY-MM-01 --to YYYY-MM-last --json`.
3. Use `totalHours` for the total.
4. Group entries by project, user, billable, or invoiced status as requested.

### Find Invoices

1. Discover or accept the company id.
2. Add project or client filters only after discovering ids with `projects list` or from prior context.
3. Run `fakturano invoices list --company <companyId> --json` for the broad set.
4. Narrow with filters such as `--status issued`, `--kind reversal`, `--issue-from`, `--issue-to`, `--number`, `--notes`, `--min-total`, and `--max-total`.
5. Use `totalAmount` for the total of returned invoices; do not recompute from human table output.

### Diagnose Authentication

1. Run `fakturano config show`.
2. Confirm base URL points to the running app.
3. Run `fakturano auth whoami --json`.
4. If HTTP 401 appears, tell the user the key is invalid or revoked and ask them to create a new API key in the app.

## Troubleshooting

- `fakturano --help` prints nothing: reinstall with `make install-cli` from the repo, then run `hash -r`.
- `command not found`: run `make install-cli`, then ensure the npm global bin directory is on `PATH`.
- `Authentication required (HTTP 401)`: key is missing, invalid, or revoked.
- `API keys cannot manage API keys (HTTP 403)`: the CLI key cannot manage keys; use the web app session UI.
- Network failure: ensure the web app is running and `--base-url` or config points to it.
- Usage failure exit code `2`: inspect the command syntax, required flags, date/time formats, and mutually exclusive `--hours` vs `--start/--end`.
- Invoice filter failure: validate enum values, date order, and `--limit <= 1000`; use `fakturano help invoices list` for the full syntax.
