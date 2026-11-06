# Add user executable directories to PATH, without duplicates.
for dir in "$HOME/bin" "$HOME/.local/bin"; do
    if [[ -d "$dir" && ":$PATH:" != *":$dir:"* ]]; then
        PATH="$dir:$PATH"
    fi
done
unset dir
