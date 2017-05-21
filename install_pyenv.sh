#!/usr/bin/env bash


# Запретить пускать от root
if [ "$EUID" == 0 ]; then
  echo "[ERROR] Dont use root"
  exit
fi


# Установка pyenv
case $( uname -s ) in
    Linux)
        curl -L https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash;;
    Darwin)
        if which brew; then
            brew install pyenv
        else
            echo "[ERROR] brew is not installed"
        fi;;
    *)
        echo "[ERROR] Your system is not supported"
        exit 1;;
esac


if [[ -f /usr/local/bin/virtualenvwrapper.sh ]]; then
    VIRTUALENVWPARRER="/usr/local/bin/virtualenvwrapper.sh"
# Red-hat based
elif [[ -f /usr/bin/virtualenvwrapper.sh ]]; then
    VIRTUALENVWPARRER="/usr/bin/virtualenvwrapper.sh"
else
    echo "You must install virtualenvwrapper globally first. Aborting." >&2;
    exit 1;
fi


echo "
================================================================================

Pyenv installed

To use virtualenvwrapper and pyenv you need to add to ~/.bashrc:

export WORKON_HOME=~/.virtualenvs
source ${VIRTUALENVWPARRER}

export PATH=\"$(realpath ~/.)/.pyenv/bin:\$PATH\"
eval \"\$(pyenv init -)\"
# Uncomment if you use pyenv virtualenv
# eval \"\$(pyenv virtualenv-init -)\"


And reload it:

source ~/.bashrc

To create virtualenv with installed python and virtualenvwrapper you need to execute:

mkvirtualenv -p \$(pyenv prefix <python version>)/bin/python <virtualenv name>
ln -s \${WORKON_HOME}/<virtualenv name> <project_root>/venv
add2virtualenv <project_root>
"

