# Herdr app configuration

The `mateo` layout and personal mods are shared. The installer links them into
Herdr's app home, along with the platform-specific keys file. It leaves existing
paths untouched and reports conflicts; compare and move existing personal
config aside before rerunning if you want to adopt the shared version.

- macOS: Cmd+Shift+N opens the worktree shortcut.
- Linux/WSL: Ctrl+Alt+Shift+N opens the worktree shortcut; Ctrl+Shift+N keeps its
  existing new-space action.

`HERDR_APP_HOME` takes precedence over `XDG_CONFIG_HOME`, then `~/.config`, as
in Herdr. Settings, app state, built-in mods, and machine credentials remain
local. Select the `mateo` layout in Herdr after installing. A link can be
replaced by an app that saves via an atomic rename; verify links after editing
configuration in the app.

Herdr Core templates in `herdr-core/templates` are linked individually into
`~/.config/herdr-core/templates` (or `$XDG_CONFIG_HOME/herdr-core/templates`).
The installer supports macOS and Linux, including a Herdr app running inside
WSL; native Windows Herdr uses a separate Windows home and is not configured
by running this script in WSL.
