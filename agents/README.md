# Shared agent configuration

`AGENTS.md` contains shared user-level instructions for Codex and Claude Code.

Run `~/.dot/install.sh` to link the instructions into `~/.agents`,
`~/.codex/AGENTS.md`, and `~/.claude/CLAUDE.md`. The installer removes only
retired skill and template symlinks that point back into this checkout; it
leaves other tools' files and links alone.

The installer never replaces an existing path. If it reports a conflict,
compare the existing content with the shared file or skill. After preserving
anything you need, move the conflicting path aside and rerun the installer.
The installer does not create downstream links through a conflicting shared
path; review all reported conflicts.
Existing agent sessions may need to be restarted to pick up changes.
