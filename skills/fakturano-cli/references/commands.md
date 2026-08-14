# Fakturano CLI Command Reference

## Table Of Contents

- Installation and availability
- Authentication and config
- Global flags
- Commands
  - Vacation self-service
  - Vacation calendar
  - Vacation administration
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
cd /Users/eraldohasanaj/Development/mini-sheet
make install-cli
hash -r
```

`make install-cli` builds the CLI and runs `npm link` from `cli/`, globally linking the `fakturano` binary. If direct execution is needed without global linking:

```bash
node /Users/eraldohasanaj/Development/mini-sheet/cli/dist/index.js --help
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

### CRM

Discover all offerings and leads for a company:

```bash
fakturano crm list --company cmp_... --json
```

Discover valid responsible users before assigning a lead:

```bash
fakturano crm members list --company cmp_... --json
```

Offering commands:

```bash
fakturano crm offerings list --company cmp_... --json
fakturano crm offerings create --company cmp_... --name "Advisory" --description "Software services" --json
fakturano crm offerings update --company cmp_... --offering off_... --description "Updated description" --json
```

Lead commands:

```bash
fakturano crm leads list --company cmp_... --json
fakturano crm leads create \
  --company cmp_... \
  --offering off_... \
  --responsible usr_... \
  --organization "Acme GmbH" \
  --source LinkedIn \
  --json
fakturano crm leads update --company cmp_... --lead lead_... --stage active_communication --json
```

Lead communication commands:

```bash
fakturano crm leads messages list --company cmp_... --lead lead_... --json
fakturano crm leads messages create \
  --company cmp_... \
  --lead lead_... \
  --direction inbound \
  --body "Interested in a call" \
  --occurred-at 2026-08-12T09:30:00+02:00 \
  --json
```

Message rules:

- Direction is from the company perspective: `outbound` means sent by us; `inbound` means received from them.
- `--body` is required plain text with a maximum of 30,000 characters.
- `--occurred-at` is required and must be an ISO 8601 date-time with `Z` or an explicit offset. The CLI normalizes it to UTC.
- Messages are append-only and returned newest-first. They cannot be edited or deleted.
- All company members may list messages. Creating messages requires company admin access.

Lead create/update fields:

- `--offering <id>`: offering ID; required when creating.
- `--responsible <id>`: company member user ID; required when creating.
- `--organization <name>` and `--contact <name>`: at least one is required when creating.
- `--email`, `--phone`, `--website`, `--source`, and `--notes`: optional text fields.
- `--stage`: one of `new`, `contacted`, `active_communication`, `cold`, `won`, or `lost`; defaults to `new` when creating.
- Updates are partial and require at least one supplied field. Pass an empty string to clear an optional text field.
- Offering and lead mutations require company admin access. Reads are available to all company members.

CRM JSON shapes:

```json
{
  "offerings": [
    {
      "id": "off_...",
      "companyId": "cmp_...",
      "name": "Advisory",
      "description": "Software services",
      "createdAt": "2026-08-12T..."
    }
  ],
  "leads": [
    {
      "id": "lead_...",
      "offeringId": "off_...",
      "responsibleUserId": "usr_...",
      "organizationName": "Acme GmbH",
      "contactName": "",
      "source": "LinkedIn",
      "stage": "active_communication",
      "messages": [
        {
          "id": "lmsg_...",
          "companyId": "cmp_...",
          "leadId": "lead_...",
          "direction": "inbound",
          "body": "Interested in a call",
          "occurredAt": "2026-08-12T07:30:00.000Z",
          "createdAt": "2026-08-12T08:00:00.000Z"
        }
      ]
    }
  ]
}
```

`crm offerings create|update` returns `{ "offering": ... }`. `crm leads create|update` returns `{ "lead": ... }`. `crm leads messages list` returns `{ "messages": [...] }`; `crm leads messages create` returns `{ "message": ... }`. `crm members list` returns `{ "members": [{ "userId", "name", "email", "role" }] }`.

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

### Vacations

Vacation flags and JSON use ISO business dates (`YYYY-MM-DD`). Human-readable vacation tables render `dd.MM.yyyy`. “Today” and booking status are evaluated in `Europe/Berlin`.

Every company member may preview, create, update, and delete only their own vacation records. Admin status does not grant control over another employee's bookings. Configuration mutations, employee balances, location assignments, and WorkOS synchronization require company admin access.

#### Personal Vacation Commands

List the current user's bookings and derived status:

```bash
fakturano vacations list --company cmp_... --json
fakturano vacations list --company cmp_... --year 2027 --status upcoming --json
```

`--status` accepts `upcoming`, `ongoing`, `past`, or `inactive`.

Inspect allowance and carry-over:

```bash
fakturano vacations summary --company cmp_... --year 2027 --json
```

Always preview before booking:

```bash
fakturano vacations preview \
  --company cmp_... \
  --start 2027-05-24 \
  --end 2027-05-28 \
  --json

fakturano vacations create \
  --company cmp_... \
  --start 2027-05-24 \
  --end 2027-05-28 \
  --json
```

Update or permanently delete one of the current user's bookings:

```bash
fakturano vacations update --company cmp_... --vacation vac_... --start 2027-05-25 --end 2027-05-28 --json
fakturano vacations delete --company cmp_... --vacation vac_... --json
```

Booking rules enforced by the API:

- Ranges are whole-day and inclusive; Monday through Friday are workdays.
- Weekends and holidays for the booking's location are not charged.
- New bookings must contain at least one chargeable day and must not overlap another booking.
- Bookings may not overdraw entitlement or fall outside active employment.
- Creation is limited to the current and next calendar year, including current-year backdating and cross-year ranges.
- Existing current/next-year bookings can be edited or deleted; older history is normally read-only.
- Carry-over comes only from the immediately previous year, requires continuous employment across New Year, and expires on 1 June.

JSON responses use these top-level shapes:

```json
{ "vacations": [], "summary": {}, "today": "2027-05-03" }
{ "preview": { "evaluation": {}, "summaryAfter": {} } }
{ "vacation": {} }
{ "summary": {}, "today": "2027-05-03" }
{ "ok": true }
```

#### Vacation Calendar

Read a month, a specific day, or filtered shared events:

```bash
fakturano vacations calendar --company cmp_... --year 2027 --month 5 --json
fakturano vacations calendar --company cmp_... --day 2027-05-25 --json
fakturano vacations calendar \
  --company cmp_... \
  --employee usr_...,usr_... \
  --location vloc_...,vloc_... \
  --event-type vacations,public_holidays \
  --json
```

Calendar flags:

- `--year <1900-9999>` and `--month <1-12>` select a month; defaults are the current Berlin month.
- `--day YYYY-MM-DD` selects one day and supplies its year/month when those flags are omitted.
- `--employee <ids>`, `--location <ids>`, and `--event-type <values>` accept comma-separated lists.
- Event types are `vacations` and `public_holidays`.
- Admins may add `--include-former true` and `--include-inactive true`; these flags are ignored for regular members.

Calendar JSON shape:

```json
{
  "today": "2027-05-03",
  "year": 2027,
  "month": 5,
  "profiles": [],
  "locations": [],
  "vacations": [],
  "holidays": []
}
```

#### Locations

Discover location and profile IDs before assignment:

```bash
fakturano vacations locations list --company cmp_... --json
fakturano vacations balances list --company cmp_... --year 2027 --json
```

Admin mutations:

```bash
fakturano vacations locations create --company cmp_... --name "Berlin Office" --json
fakturano vacations locations update --company cmp_... --location vloc_... --name "Berlin" --json
fakturano vacations locations assign --company cmp_... --location vloc_... --profile vprof_... --json
fakturano vacations locations archive --company cmp_... --location vloc_... --json
fakturano vacations locations restore --company cmp_... --location vloc_... --json
fakturano vacations locations delete --company cmp_... --location vloc_... --json
```

Location names are 1–120 characters and unique case-insensitively. Only unreferenced locations can be deleted. Before archiving, reassign active employees and resolve blocking ongoing/future bookings; otherwise the API rejects the operation.

#### Public Holidays

List holidays by year and/or one or more locations:

```bash
fakturano vacations holidays list --company cmp_... --year 2027 --location vloc_...,vloc_... --json
```

Admin mutations:

```bash
fakturano vacations holidays create --company cmp_... --location vloc_... --name "Tag der Arbeit" --date 2027-05-01 --json
fakturano vacations holidays update --company cmp_... --holiday vhol_... --location vloc_... --name "Updated name" --date 2027-05-01 --json
fakturano vacations holidays delete --company cmp_... --holiday vhol_... --json
```

A location may have only one holiday per date. Holiday names are 1–120 characters. Changes that would overdraw committed bookings are rejected.

#### Policies And Overrides

Discover policy and override IDs:

```bash
fakturano vacations policies list --company cmp_... --json
fakturano vacations overrides list --company cmp_... --json
```

Admin policy commands:

```bash
fakturano vacations policies create --company cmp_... --year 2027 --allowance-days 30 --json
fakturano vacations policies copy --company cmp_... --source-year 2027 --target-year 2028 --copy-overrides false --json
fakturano vacations policies update --company cmp_... --policy vpol_... --allowance-days 31 --json
fakturano vacations policies delete --company cmp_... --policy vpol_... --json
```

Admin employee override commands:

```bash
fakturano vacations overrides set --company cmp_... --profile vprof_... --year 2027 --allowance-days 35 --json
fakturano vacations overrides delete --company cmp_... --override vovr_... --json
```

Allowances are integers from 0 through 366. An override replaces the company policy for that employee/year. Create the yearly company policy before setting overrides. Policy and override changes that would overdraw existing bookings are rejected. Policy copying never copies overrides unless `--copy-overrides true` is supplied.

Historical configuration windows are enforced by the API: January through May permits previous-year and later changes; June through December permits current-year and later changes.

#### Balances And WorkOS Employee Sync

Admins can inspect all employee balances and obtain profile IDs:

```bash
fakturano vacations balances list --company cmp_... --year 2027 --json
```

Balance output includes entitlement, carry-over, taken, upcoming, available, current location, and active/former status.

WorkOS synchronization is deliberately preview-first:

```bash
# Safe preview; no changes are written.
fakturano vacations employees sync --company cmp_... --json

# Apply only after reviewing added, updated, and departed arrays.
fakturano vacations employees sync --company cmp_... --apply true --json
```

WorkOS is authoritative for company membership, role, name, and email. Apply refetches WorkOS and reconciles employee profiles under a company lock. A detected departure ends employment on the sync date; the departure date itself is excluded. Sync is rejected if the resulting employment state would overdraw committed bookings.

Sync JSON shape:

```json
{
  "sync": {
    "added": [],
    "updated": [],
    "departed": [],
    "applied": false
  }
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
fakturano crm list --company "$company_id" --json
fakturano crm members list --company "$company_id" --json
fakturano crm leads messages list --company "$company_id" --lead "$lead_id" --json
fakturano invoices list --company "$company_id" --status issued --json
fakturano vacations summary --company "$company_id" --year 2027 --json
fakturano vacations calendar --company "$company_id" --year 2027 --month 5 --json
fakturano timesheet list --company "$company_id" --from 2026-07-01 --to 2026-07-31 --json
```

Bad:

```bash
fakturano companies list | grep ...
```

## Workflows

### Preview And Book Vacation

1. Discover the company with `fakturano companies list --json`.
2. Inspect allowance with `fakturano vacations summary --company <companyId> --year YYYY --json`.
3. Inspect existing bookings and shared events with `vacations list` and `vacations calendar`.
4. Preview the exact inclusive range with `vacations preview --start YYYY-MM-DD --end YYYY-MM-DD --json`.
5. Explain charged days and exclusions if needed, then create only after the range is correct.
6. Confirm the returned vacation ID and derived charged days.

### Configure A Vacation Year

1. Verify admin role with `fakturano auth whoami --json`.
2. Discover locations, policies, overrides, and balances with their `list` commands.
3. Create or copy the yearly policy.
4. Set only required employee overrides, using profile IDs from `balances list`.
5. Add location-specific public holidays.
6. Re-run `balances list` and `calendar` to verify the result.

### Synchronize Vacation Employees

1. Verify admin role and select the company.
2. Run `fakturano vacations employees sync --company <companyId> --json` without `--apply true`.
3. Review every added, updated, and departed employee; ask the user before applying if intent is ambiguous.
4. Apply with `--apply true --json`.
5. Re-run the preview and `balances list` to confirm the resulting employee state and locate employees needing location assignment.

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

### Create And Progress A CRM Lead

1. Discover the company with `fakturano companies list --json`.
2. Discover or create an offering with `fakturano crm list --company <companyId> --json` or `crm offerings create`.
3. Discover the responsible user with `fakturano crm members list --company <companyId> --json`.
4. Create the lead with `fakturano crm leads create ... --json`.
5. Progress it with `fakturano crm leads update --lead <leadId> --stage <stage> --json`.
6. Preserve unrelated lead fields by sending only changed flags.

### Review And Record CRM Communication

1. Discover the company and lead with `fakturano crm list --company <companyId> --json`.
2. Read the current newest-first history with `fakturano crm leads messages list --company <companyId> --lead <leadId> --json`.
3. Determine direction from the company perspective: use `outbound` for a message sent by us and `inbound` for a message received from them.
4. Record it with `fakturano crm leads messages create`, including the exact plain-text body and a timezone-aware `--occurred-at` value.
5. Report the created message id, direction, and normalized occurrence timestamp. Do not imply that the CLI sent or synchronized the message.

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
- CRM mutation HTTP 403: the API-key user is not an admin for that company.
- CRM relationship failure: rediscover offering IDs with `crm list` and responsible user IDs with `crm members list`.
- CRM validation failure: use an allowed stage, provide an organization or contact on create, and provide at least one field on update.
- CRM message validation failure: use `outbound` or `inbound`, provide a non-empty body of at most 30,000 characters, and include `Z` or an explicit offset in `--occurred-at`.
- CRM message HTTP 403: listing is available to members, but recording a message requires admin membership.
- CRM message lead not found: rediscover the tenant-scoped lead ID with `crm list`; lead IDs from another company return HTTP 404.
- Vacation booking failure: preview the same range and inspect overlap, active employment, current/next-year limits, zero-charge ranges, location holidays, and available allowance.
- Vacation mutation HTTP 403: users may mutate only their own bookings; configuration, balances, assignments, and WorkOS sync require admin access.
- Missing vacation profile or location: ask an admin to preview/apply WorkOS employee sync, then assign the employee to an active location.
- Vacation policy/holiday/override rejection: the change is historical, references missing records, or would overdraw existing bookings; inspect policies, overrides, balances, and calendar before retrying.
- Location archive failure: reassign active profiles and resolve ongoing/future vacations that snapshot the location; delete only unreferenced locations.
- WorkOS sync failure: verify WorkOS credentials and organization linkage, preview first, and resolve any resulting balance overdraw before applying.
