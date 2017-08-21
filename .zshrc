#!/bin/zsh

LC_ALL="en_US"

source ~/.zsh/aliases.zsh
source ~/.zsh/bindkeys.zsh
source ~/.zsh/exports.zsh
source ~/.zsh/functions.zsh
source ~/.zsh/history.zsh
source ~/.zsh/prompt.zsh

# Disable auto-correct
unsetopt correct_all

# EXPORTS {{{
export EDITOR='vim'

# Compilation flags
export ARCHFLAGS="-arch x86_64"

# Postgres data file path
export PGDATA='/usr/local/var/postgres/data'

# Set locale
export LANG=en_US.UTF-8

# PATH
export PATH="/usr/local/bin:$PATH"
export PATH="$PATH:$HOME/.dotfiles/bin"
export PATH="$PATH:/usr/local/share/npm/bin"

# }}}

# CHRUBY {{{

[[ -s /usr/local/opt/chruby/share/chruby/chruby.sh ]] && . /usr/local/opt/chruby/share/chruby/chruby.sh
[[ -s /usr/local/opt/chruby/share/chruby/auto.sh ]] && . /usr/local/opt/chruby/share/chruby/auto.sh

# }}}

# BUNDLER EXEC {{{

[ -f ~/.bundler-exec.sh ] && source ~/.bundler-exec.sh

# }}}

# AUTOJUMP {{{

command -v brew >/dev/null 2>&1 && [[ -s `brew --prefix`/etc/autojump.sh ]] && . `brew --prefix`/etc/autojump.sh

# }}}

# vim: foldmarker={{{,}}} foldmethod=marker foldlevel=0:
