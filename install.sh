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

add_source "$HOME/.zprofile" 'source ~/.dot/zprofile'
add_source "$HOME/.zshrc" 'source ~/.dot/zshrc'
mkdir -p "$HOME/.config"
link_config "$dotdir/nvim" "$HOME/.config/nvim"
link_config "$dotdir/kitty" "$HOME/.config/kitty"
link_config "$dotdir/vim" "$HOME/.vim"
