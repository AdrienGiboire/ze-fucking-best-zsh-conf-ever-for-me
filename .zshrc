#!/bin/zsh

LC_ALL="en_US"

source ~/.zsh/aliases.zsh
source ~/.zsh/bindkeys.zsh

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

# FUNCTIONS {{{

function migrate() {
  # if we have a name for the migration AND some `field:type` property
  if [ 2 -le $# ]; then
    drails g migration $@
    drake db:migrate

  # if we just have a migration name
  elif [ 1 -le $# ]; then
    drails g migration $@

  # if we have nothing we just migrate the DB
  elif [ 0 -le $# ]; then
    drake db:migrate
  fi
}

function up() {
  local current_branch=`git rev-parse --abbrev-ref HEAD`
  git stash save "before updating the master branch" &&
  git co master &&
  git fa &&
  git pullr &&
  git co $current_branch &&
  git rebase master &&
  bundle install &&
  drake db:migrate &&
  git stash pop
}

function deploy() {
  local current_branch=`git rev-parse --abbrev-ref HEAD`
  local target_branch=$1
  local force_mode=$2

  git stash save --include-untracked "before deploying '$current_branch' to '$target_branch'" &&
  git pullr &&
  git push &&
  git co $target_branch &&
  git pullr &&
  git merge $current_branch &&
  git push &&
  sh .travis/deploy.sh $target_branch &&
  git co $current_branch &&
  git stash pop
}

function update_current_branch() {
  local current_branch=`git rev-parse --abbrev-ref HEAD`
  local source_branch='master'

  # if we have a branch as argument
  if [ 1 -le $# ]; then
    source_branch=$1
  fi

  git stash save "before updating '$current_branch' from '$source_branch'"
  git co $source_branch
  git pullr
  git co $current_branch
  git merge $source_branch
  git stash pop
}

function update_db() {
  echo "dropping db" && drake db:drop
  echo "creating db" && drake db:create
  echo "migrating db" && drake db:migrate

  cd /tmp
  if [ -f /tmp/octoly_production.sql ]; then
    rm -fr /tmp/octoly_production.sql
  fi

  echo "dumping data from production"
  source ~/.env
  ssh octo-redis "PGPASSWORD=$PG_PASS pg_dump --data-only -h $PG_HOST -U $PG_USER -d $PG_DB -c > octoly_production.sql"

  echo "downloading data" && scp octo-redis:/mnt/tmp/octoly_production.sql /tmp
  echo "restoring data"
  PGPASSWORD=octoly psql -U octoly -d octoly_development < octoly_production.sql

  echo "clean production" && ssh octo-redis 'rm -fr /mnt/tmp/octoly_production.sql'
  cd -
}

# }}}

# vim: foldmarker={{{,}}} foldmethod=marker foldlevel=0:
