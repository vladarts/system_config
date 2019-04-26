#!/usr/bin/env bash

#: VladArts CLI tools
source ${HOME}/dev/system_config/bashrc/main.sh

#: Python tools
export VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python3
export WORKON_HOME=${HOME}/.virtualenvs
source /usr/local/bin/virtualenvwrapper.sh

export PATH="${HOME}/.pyenv/bin:$PATH"
eval "$(pyenv init -)"

#: Java tools
export JAVA_HOME=$(/usr/libexec/java_home)

#: SDKman
export SDKMAN_DIR="${HOME}/.sdkman"
[[ -s "${HOME}/.sdkman/bin/sdkman-init.sh" ]] && source "${HOME}/.sdkman/bin/sdkman-init.sh"

#: PATH overrides
export PATH=~/bin:$PATH
export PATH=${PATH}:/usr/local/sbin

#: Correct bash history processing
shopt -s histappend

#: Postfix local logs
alias postfix_logs="log stream --predicate  '(process == "smtpd") || (process == "smtp")' --info"

#: Bash completion
[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion
