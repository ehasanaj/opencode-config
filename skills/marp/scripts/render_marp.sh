#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: render_marp.sh <input.md> <html|pdf|pptx|png|jpeg|notes> [output] [extra marp args...]

Examples:
  render_marp.sh deck.md html
  render_marp.sh deck.md pdf build/deck.pdf
  render_marp.sh deck.md pptx build/deck.pptx --allow-local-files
  render_marp.sh deck.md png build/title.png
  render_marp.sh deck.md notes build/notes.txt
EOF
}

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -lt 2 ]]; then
  usage
  exit 1
fi

input=$1
format=$2
output=

if [[ ! -f "$input" ]]; then
  printf 'Input file not found: %s\n' "$input" >&2
  exit 1
fi

shift 2
if [[ $# -gt 0 && ${1:-} != -* ]]; then
  output=$1
  shift 1
fi

case "$format" in
  html)
    mode=()
    extension=html
    ;;
  pdf)
    mode=(--pdf)
    extension=pdf
    ;;
  pptx)
    mode=(--pptx)
    extension=pptx
    ;;
  png)
    mode=(--image png)
    extension=png
    ;;
  jpeg)
    mode=(--image jpeg)
    extension=jpeg
    ;;
  notes)
    mode=(--notes)
    extension=txt
    ;;
  *)
    printf 'Unsupported format: %s\n' "$format" >&2
    usage
    exit 1
    ;;
esac

if [[ -z "$output" ]]; then
  input_dir=$(dirname "$input")
  base_name=$(basename "$input")
  stem=${base_name%.*}
  output="${input_dir}/${stem}.${extension}"
fi

if [[ -x "./node_modules/.bin/marp" ]]; then
  runner=(./node_modules/.bin/marp)
else
  runner=(npx @marp-team/marp-cli@latest)
fi

printf 'Rendering %s -> %s (%s)\n' "$input" "$output" "$format"
"${runner[@]}" "$input" "${mode[@]}" -o "$output" "$@"
