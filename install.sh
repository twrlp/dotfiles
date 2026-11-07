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

unlink_repo_skill() {
  name="$1"
  target="$dotdir/agents/skills/$name"
  agents_link="$HOME/.agents/skills/$name"
  claude_link="$HOME/.claude/skills/$name"
  if [ -L "$agents_link" ] && [ "$(readlink "$agents_link")" = "$target" ]; then
    rm "$agents_link"
    printf 'Removed stale skill link %s\n' "$agents_link"
  fi
  if [ -L "$claude_link" ]; then
    claude_target=$(readlink "$claude_link")
    if [ "$claude_target" = "$target" ] || [ "$claude_target" = "$agents_link" ] || [ "$claude_target" = "../../.agents/skills/$name" ]; then
      rm "$claude_link"
      printf 'Removed stale skill link %s\n' "$claude_link"
    fi
  fi
}

unlink_repo_template() {
  name="$1"
  target="$dotdir/herdr-core/templates/$name"
  link="${XDG_CONFIG_HOME:-$HOME/.config}/herdr-core/templates/$name"
  if [ -L "$link" ] && [ "$(readlink "$link")" = "$target" ]; then
    rm "$link"
    printf 'Removed stale template link %s\n' "$link"
  fi
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

# Remove repo-managed links for skills retired from this checkout.
unlink_repo_skill development-workflow
unlink_repo_skill feature-planning
unlink_repo_skill feature-review

for skill in "$dotdir"/agents/skills/*; do
  [ -f "$skill/SKILL.md" ] || continue
  name=${skill##*/}
  link_config "$skill" "$HOME/.agents/skills/$name"
  if [ -L "$HOME/.agents/skills/$name" ] && [ "$(readlink "$HOME/.agents/skills/$name")" = "$skill" ]; then
    link_config "$HOME/.agents/skills/$name" "$HOME/.claude/skills/$name"
  fi
done

# Remove links for the Herdr Core templates retired from this checkout.
unlink_repo_template docs-writer.md
unlink_repo_template feature-owner.md
unlink_repo_template implementer.md
unlink_repo_template reviewer.md
unlink_repo_template ux-validator.md

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
