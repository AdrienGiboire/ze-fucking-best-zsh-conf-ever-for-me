function git_branch {
  if [ -e .git ]; then
    local current_branch="$(git b | grep -e '*' | cut -d ' ' -f2)"
    echo " (${PR_BLUE}${current_branch}%{$reset_color%})"
  fi
}

function ruby_version {
  if [ -e .ruby-version ]; then
    local ruby_version="$(cat .ruby-version)"
    echo " (${PR_YELLOW}${ruby_version}%{$reset_color%})"
  fi
}

typeset -g current_pwd="$(pwd | sed -e "s,^$HOME,~,")"

function _update_current_pwd {
  current_pwd="$(pwd | sed -e "s,^$HOME,~,")"
}

chpwd_functions+=(_update_ruby_version _update_current_pwd)
PROMPT='
${PR_GREEN}${current_pwd}%{$reset_color%}$(ruby_version)$(git_branch)
> '
