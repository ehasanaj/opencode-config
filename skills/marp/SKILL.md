---
name: marp
description: Create and edit Markdown slide decks with Marp and render them with Marp CLI. Use when working on Marp or Marpit presentations, `@marp-team/marp-cli`, `marp.config.*`, custom Marp themes, or Markdown slide files that need HTML, PDF, PPTX, PNG/JPEG, speaker notes, preview, watch, or server workflows.
---

# Marp

## Overview

Author slides as Markdown first, then render them through Marp CLI. Use this skill for both new decks and edits to existing Marp presentations, especially when output format, theme behavior, or CLI configuration matters.

## Workflow

1. Determine the task:
   - **New deck**: Start from `assets/starter.md` and fill in theme, title, audience, and slide outline.
   - **Existing deck**: Edit the Markdown directly and preserve the deck's current theme and output assumptions unless the user asks to change them.
   - **Theme or config work**: Read `references/authoring.md` and `references/cli.md` before editing CSS or `marp.config.*`.
2. Check the runtime:
   - Prefer a project-local `./node_modules/.bin/marp` when available.
   - Otherwise use `npx @marp-team/marp-cli@latest`.
   - PDF, PPTX, and image exports require Node.js 18+ and an installed browser: Chrome, Edge, or Firefox.
   - Editable PPTX also requires LibreOffice Impress.
3. Author the deck:
   - Put deck-wide settings in YAML front matter.
   - Separate slides with `---`.
   - Use HTML comments for presenter notes.
   - Split dense content into more slides instead of shrinking text until it barely fits.
4. Render and verify:
   - Use `scripts/render_marp.sh` for standard single-file exports.
   - Use watch or preview while iterating on HTML output.
   - Re-export the target format after edits and verify the result.
5. Read detailed references only when needed:
   - `references/authoring.md`: directives, notes, backgrounds, built-in themes, transitions, custom theme CSS.
   - `references/cli.md`: install modes, output flags, config files, browser behavior, templates, metadata.

## Authoring Defaults

- Default to `theme: default` or `theme: gaia` unless the user asks for a specific visual language.
- Default to `size: 16:9`. Use `4:3` only when required by the venue or source material.
- Keep one main idea per slide. Prefer more slides over overfilled layouts.
- Prefer deck-wide CSS via `style:` front matter or a reusable theme file. Use `<style scoped>` only for one-slide exceptions.
- Use `header` and `footer` directives only when repeated context genuinely helps navigation.
- Use background images sparingly. If the deck must stay portable across HTML, PDF, and PPTX, prefer simple `![bg]()` backgrounds over advanced effects.
- Use `transition` only when the deck will actually be viewed as HTML in the `bespoke` template. Do not promise the same effect in PDF or PPTX.

## Rendering Patterns

- One-off HTML export:
  ```bash
  npx @marp-team/marp-cli@latest deck.md -o deck.html
  ```
- PDF export:
  ```bash
  npx @marp-team/marp-cli@latest deck.md --pdf -o deck.pdf
  ```
- PPTX export:
  ```bash
  npx @marp-team/marp-cli@latest deck.md --pptx -o deck.pptx
  ```
- Watch while authoring:
  ```bash
  npx @marp-team/marp-cli@latest -w deck.md
  ```
- Preview window:
  ```bash
  npx @marp-team/marp-cli@latest -p deck.md
  ```
- Use `scripts/render_marp.sh <input.md> <html|pdf|pptx|png|jpeg|notes> [output]` for the common single-file cases.

## Editing Guidance

- If the user gives prose, turn it into a slide outline before polishing wording.
- If the deck already has front matter, keep related settings together instead of scattering per-slide overrides.
- If the user asks for a custom theme, prefer a separate `.css` theme file once styling goes beyond a few rules.
- If the deck uses local images and the requested output is PDF, PPTX, or image, remember `--allow-local-files` for trusted content only.
- If a render fails, check runtime assumptions first: missing browser, missing local assets, unsupported transition expectations, or wrong output flag.

## References

- Read `references/authoring.md` when working on Markdown structure, directives, images, notes, themes, or transitions.
- Read `references/cli.md` when working on export behavior, configuration files, template choice, browsers, metadata, or advanced CLI flags.
- Copy `assets/starter.md` when creating a new deck from scratch.
- Copy `assets/custom-theme.css` when the deck needs a reusable theme file instead of inline tweaks.

## Resources

### scripts/

`scripts/render_marp.sh` wraps the common single-file render flows and prefers a project-local `marp` binary when present.

### references/

Use `references/authoring.md` for syntax and theme behavior, and `references/cli.md` for CLI behavior and export caveats.

### assets/

Use `assets/starter.md` as a new-deck template and `assets/custom-theme.css` as a starting point for reusable theme CSS.
