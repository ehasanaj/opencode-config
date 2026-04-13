# Marp Authoring Reference

## Contents

1. Minimal deck
2. Front matter and slide boundaries
3. Useful directives
4. Presenter notes
5. Images and backgrounds
6. Built-in themes and theme classes
7. Custom theme CSS
8. HTML-specific transitions

## Minimal deck

```markdown
---
theme: default
paginate: true
title: Example deck
---

# Title slide

Intro sentence.

---

## Slide two

- Point one
- Point two
```

Use YAML front matter for deck-wide defaults. Separate slides with `---`.

## Front matter and slide boundaries

- Put global settings in the opening `---` front matter block.
- Use a plain `---` between slides.
- Keep deck metadata near the top: `title`, `description`, `author`, `keywords`, `url`, `image`.
- Common global directives for Marp decks:
  - `theme`
  - `paginate`
  - `size`
  - `style`
  - `headingDivider`
  - `math`

## Useful directives

Global directives apply to the whole deck. Local directives apply from the current slide onward. Prefix a local directive with `_` to affect only the current slide.

Examples:

```markdown
---
theme: gaia
paginate: true
size: 16:9
header: Product roadmap
footer: Internal draft
style: |
  section {
    font-size: 28px;
  }
---
```

```markdown
<!-- _class: lead -->
<!-- _backgroundColor: #0b1020 -->
<!-- _color: white -->
```

Common local directives:

- `paginate`
- `header`
- `footer`
- `class`
- `backgroundColor`
- `backgroundImage`
- `backgroundPosition`
- `backgroundRepeat`
- `backgroundSize`
- `color`

Pagination values:

- `true`: show and increment
- `false`: hide and increment
- `hold`: show and do not increment
- `skip`: hide and do not increment

## Presenter notes

Presenter notes are plain HTML comments that are not parsed as directives.

```markdown
# Demo slide

<!-- Mention the customer example here. -->
<!-- Keep the timing under 90 seconds. -->
```

These notes can be exported with `--notes` and regular PPTX export also carries presenter notes.

## Images and backgrounds

Inline image sizing:

```markdown
![w:240](./diagram.png)
![width:200px height:120px](./chart.png)
```

Background images:

```markdown
![bg](./cover.jpg)
![bg contain](./product-shot.png)
![bg left:33%](./portrait.jpg)
```

Useful rules:

- `![bg]()` makes the image a slide background.
- `cover` is the default background fit mode.
- `contain` or `fit` preserves the whole image.
- `left` and `right` create split layouts and shrink the content area.
- Simple background patterns are the most portable across HTML, PDF, and PPTX.

Marpit also supports image filters, multiple backgrounds, and advanced background layouts. Use them only when needed because they add complexity and are harder to debug than simple `bg` usage.

## Built-in themes and theme classes

Marp Core ships these built-in themes:

- `default`
- `gaia`
- `uncover`

Useful built-in classes:

- `invert`: supported by all built-in themes
- `lead`: useful in `gaia` for title or section-intro slides
- `gaia`: extra color scheme for the `gaia` theme

Examples:

```markdown
---
theme: gaia
class: lead
size: 4:3
---
```

```markdown
<!-- _class: invert -->
```

## Custom theme CSS

Prefer a reusable `.css` theme file once styling goes beyond a few inline rules.

Minimal theme:

```css
/* @theme custom-clean */

:root {
  width: 1280px;
  height: 720px;
  padding: 56px;
  font-size: 30px;
  color: #0f172a;
  background: #f8fafc;
}

h1,
h2 {
  color: #0f766e;
}
```

Important theme rules:

- `/* @theme name */` is required.
- Style `section` or `:root` as the slide viewport.
- Use absolute units for slide size.
- `:root` in a Marp theme targets each slide, not the page's HTML root.
- Use `@import 'base-theme';` to inherit from another registered theme.
- Use `@size name width height` metadata to define custom size presets.
- Use `@auto-scaling` metadata if the theme should support fitting headers or auto-scaled code and math.

## HTML-specific transitions

Marp CLI's `bespoke` template supports `transition` as a local directive for HTML presentation mode.

```markdown
---
transition: fade
---

# First slide

---

<!-- _transition: cover -->

# Second slide
```

Useful notes:

- Transitions matter in HTML viewing, not static PDF output.
- Built-in transitions include `fade`, `cover`, `slide`, `swap`, `wipe`, `zoom`, and many others.
- A duration can be included, for example `transition: fade 1s`.
- For custom transitions, define CSS keyframes with the `marp-transition-...` naming convention.
- Morph-like animations are possible with `view-transition-name`, but only matter in supported browsers.

Upstream docs:

- `https://marpit.marp.app/directives`
- `https://marpit.marp.app/image-syntax`
- `https://marpit.marp.app/theme-css`
- `https://github.com/marp-team/marp-cli/tree/main/docs/bespoke-transitions`
