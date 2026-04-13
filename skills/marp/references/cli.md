# Marp CLI Reference

## Contents

1. Runtime and install choices
2. Common commands
3. Output-specific caveats
4. Watch, preview, and server modes
5. Themes and metadata
6. Config files
7. Advanced options worth remembering

## Runtime and install choices

Marp CLI is the renderer and exporter for Marp slide decks.

- Node.js 18+ is required.
- For one-off usage, prefer:

```bash
npx @marp-team/marp-cli@latest deck.md
```

- For repo-managed usage, prefer a local dependency and `npx marp`.
- PDF, PPTX, and image exports need Chrome, Edge, or Firefox installed.
- Editable PPTX also needs LibreOffice Impress.

Other install paths exist, but they are secondary for skill usage:

- `npm install --save-dev @marp-team/marp-cli`
- `npm install -g @marp-team/marp-cli`
- `brew install marp-cli`
- standalone binary
- Docker image

## Common commands

HTML output is the default:

```bash
marp deck.md
marp deck.md -o deck.html
```

Other common outputs:

```bash
marp deck.md --pdf -o deck.pdf
marp deck.md --pptx -o deck.pptx
marp deck.md --image png -o title.png
marp deck.md --images png
marp deck.md --notes -o notes.txt
```

Useful project-scale patterns:

```bash
marp slides/*.md
marp --input-dir ./slides --output ./dist ./slides
marp --theme-set ./themes --pdf deck.md -o deck.pdf
```

## Output-specific caveats

PDF:

- Use `--pdf-notes` to add presenter notes as PDF annotations.
- Use `--pdf-outlines` to add bookmarks.

PPTX:

- Regular `--pptx` preserves appearance better than editable PPTX.
- `--pptx-editable` is experimental, lower-fidelity, and does not support presenter notes.

Images:

- `--image png|jpeg` exports only the first slide.
- `--images png|jpeg` exports each slide separately.
- `--image-scale` increases render resolution.

Local assets:

- Browser-based conversions block local file access by default.
- Use `--allow-local-files` only for trusted Markdown.

## Watch, preview, and server modes

Watch mode:

```bash
marp -w deck.md
```

Preview window:

```bash
marp -p deck.md
```

Server mode:

```bash
marp -s ./slides
```

Useful notes:

- `-p` implies a live preview workflow and is good for authoring.
- `-s` serves decks on demand instead of writing files to disk.
- In server mode, query strings like `?pdf` and `?pptx` request converted output.
- Set `PORT=5000` to change the default server port.

## Themes and metadata

Override the theme directly:

```bash
marp --theme gaia deck.md
marp --theme ./themes/custom.css deck.md
```

Register a theme set:

```bash
marp --theme-set ./themes -- deck.md
```

CLI metadata flags override front matter:

- `--title`
- `--description`
- `--author`
- `--keywords`
- `--url`
- `--og-image`

Template choice:

- `bespoke` is the default and supports navigation, presenter view, fragments, and transitions.
- `bare` is the simpler template with fewer runtime features.

## Config files

Use config files when a deck project has stable defaults.

Supported config locations include:

- `marp.config.js`
- `marp.config.mjs`
- `marp.config.cjs`
- `marp.config.ts`
- `.marprc` in JSON or YAML
- `marp` section in `package.json`

Example:

```yaml
allowLocalFiles: true
themeSet: ./themes
pdf: true
```

Or:

```javascript
export default {
  inputDir: './slides',
  output: './dist',
  themeSet: './themes',
}
```

Use `--config-file` to point at a specific config. Use `--no-config-file` when you need a clean run.

## Advanced options worth remembering

- `--browser firefox,chrome` to prefer specific browsers.
- `--browser-path /path/to/browser` when auto-detection fails.
- `--browser-timeout 60` for slower environments.
- `--template bare|bespoke` to switch HTML runtime behavior.
- `--parallel` or `--no-parallel` when converting many files.
- `--html` to allow raw HTML content in Markdown when the deck needs it.
- `--engine` for Marpit-based custom engines or plugins.
- `--version` to confirm which Marp Core engine is actually being used.

Upstream docs:

- `https://github.com/marp-team/marp-cli`
- `https://github.com/marp-team/marp-core`
- `https://github.com/marp-team/marpit`
