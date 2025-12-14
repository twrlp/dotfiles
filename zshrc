# Command history settings
HISTFILE=~/.histfile
HISTSIZE=2000
SAVEHIST=2000

# Autocomplete
autoload -Uz compinit
compinit

# Require cd to change dirs
setopt noautocd

# Use Vim keys
bindkey -v

# Prompt setup
PROMPT='%m:%c %# '

# Alias-es
alias please='sudo '

