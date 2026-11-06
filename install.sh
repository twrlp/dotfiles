#!/bin/sh
set -eu

dotdir="$HOME/.dot"

if [ ! -d "$dotdir/.git" ] && [ ! -f "$dotdir/.git" ]; then
  printf 'Expected a Git checkout at %s\n' "$dotdir" >&2
  exit 1
fi

git -C "$dotdir" submodule update --init --recursive

add_source() {
  file="$1"
  line="$2"
  if [ -L "$file" ] && [ ! -e "$file" ]; then
    printf 'Skipping broken symlink: %s\n' "$file" >&2
    return
  fi
  if [ -e "$file" ] && [ ! -f "$file" ]; then
    printf 'Skipping non-file: %s\n' "$file" >&2
    return
  fi
  if [ -f "$file" ] && grep -Fqx "$line" "$file"; then
    return
  fi
  # Ensure the new command starts on its own line, even without a final newline.
  if [ -s "$file" ] && [ -n "$(tail -c 1 "$file")" ]; then
    printf '\n' >> "$file"
  fi
  printf '%s\n' "$line" >> "$file"
  printf 'Updated %s\n' "$file"
}

link_config() {
  target="$1"
  link="$2"
  if [ -L "$link" ] && [ "$(readlink "$link")" = "$target" ]; then
    return
  fi
  if [ -e "$link" ] || [ -L "$link" ]; then
    printf 'Skipping existing path: %s\n' "$link" >&2
    return
  fi
  ln -s "$target" "$link"
  printf 'Linked %s\n' "$link"
}

add_source "$HOME/.zshenv" 'source ~/.dot/zshenv'
add_source "$HOME/.zprofile" 'source ~/.dot/zprofile'
add_source "$HOME/.zshrc" 'source ~/.dot/zshrc'
mkdir -p "$HOME/.config"
link_config "$dotdir/nvim" "$HOME/.config/nvim"
link_config "$dotdir/kitty" "$HOME/.config/kitty"
link_config "$dotdir/vim" "$HOME/.vim"

# Keep agent-owned directories writable and link only the shared entries.
mkdir -p "$HOME/.agents/skills" "$HOME/.codex" "$HOME/.claude/skills"
link_config "$dotdir/agents/AGENTS.md" "$HOME/.agents/AGENTS.md"
if [ -L "$HOME/.agents/AGENTS.md" ] && [ "$(readlink "$HOME/.agents/AGENTS.md")" = "$dotdir/agents/AGENTS.md" ]; then
  link_config "$HOME/.agents/AGENTS.md" "$HOME/.codex/AGENTS.md"
  link_config "$HOME/.agents/AGENTS.md" "$HOME/.claude/CLAUDE.md"
fi
for skill in "$dotdir"/agents/skills/*; do
  [ -f "$skill/SKILL.md" ] || continue
  name=${skill##*/}
  link_config "$skill" "$HOME/.agents/skills/$name"
  if [ -L "$HOME/.agents/skills/$name" ] && [ "$(readlink "$HOME/.agents/skills/$name")" = "$skill" ]; then
    link_config "$HOME/.agents/skills/$name" "$HOME/.claude/skills/$name"
  fi
done

# Share personal Herdr configuration without replacing machine-owned files.
case "$(uname -s)" in
  Darwin) herdr_keys=keys-macos.json ;;
  Linux)  herdr_keys=keys-linux.json ;;
  *)      herdr_keys= ;;
esac
if [ -n "$herdr_keys" ]; then
  herdr_home="${HERDR_APP_HOME:-${XDG_CONFIG_HOME:-$HOME/.config}/herdr-app}"
  mkdir -p "$herdr_home/layouts" "$herdr_home/mods"
  link_config "$dotdir/herdr-app/$herdr_keys" "$herdr_home/keys.json"
  link_config "$dotdir/herdr-app/layouts/mateo.json" "$herdr_home/layouts/mateo.json"
  for mod in "$dotdir"/herdr-app/mods/*; do
    [ -f "$mod/mod.json" ] || continue
    link_config "$mod" "$herdr_home/mods/${mod##*/}"
  done
fi

# Templates are shared individually so machine-local templates can coexist.
core_templates="${XDG_CONFIG_HOME:-$HOME/.config}/herdr-core/templates"
mkdir -p "$core_templates"
for template in "$dotdir"/herdr-core/templates/*.md; do
  [ -f "$template" ] || continue
  link_config "$template" "$core_templates/${template##*/}"
done
