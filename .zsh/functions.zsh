function extract {
  echo Extracting $1 ...
  if [ -f $1 ] ; then
      case $1 in
          *.tar.bz2) tar xjf $1    ;;
          *.tar.gz)  tar xzf $1    ;;
          *.bz2)     bunzip2 $1    ;;
          *.rar)     unrar x $1    ;;
          *.gz)      gunzip $1     ;;
          *.tar)     tar xf $1     ;;
          *.tbz2)    tar xjf $1    ;;
          *.tgz)     tar xzf $1    ;;
          *.zip)     unzip $1      ;;
          *.Z)       uncompress $1 ;;
          *.7z)      7z x $1       ;;
          *)         echo "'$1' cannot be extracted via extract()" ;;
      esac
  else
      echo "'$1' is not a valid file"
  fi
}

function migrate {
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

function up {
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

function deploy {
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

function update_current_branch {
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

function update_db {
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
