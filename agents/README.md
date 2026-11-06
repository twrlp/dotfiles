# Shared agent configuration

`AGENTS.md` contains shared user-level instructions for Codex and Claude Code.
`skills/` contains the custom skills shared by both agents.

Run `~/.dot/install.sh` to link the instructions into `~/.agents`,
`~/.codex/AGENTS.md`, and `~/.claude/CLAUDE.md`, and link each skill into
`~/.agents/skills` and `~/.claude/skills`. The directories themselves remain
separate, so other tools can install their own skills without adding them to
this repository. Codex discovers the shared skills in `~/.agents/skills`.

The installer never replaces an existing path. If it reports a conflict,
compare the existing content with the shared file or skill. After preserving
anything you need, move the conflicting path aside and rerun the installer.
The installer does not create downstream links through a conflicting shared
path; review all reported conflicts.
Existing agent sessions may need to be restarted to pick up changes.
