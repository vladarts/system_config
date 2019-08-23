#!/usr/bin/env bash


setup_python_virtualenv ()
{
  echo "Installed pyenv versions:"
  pyenv versions

  read -r -p "Choose pyenv version: " pyenv_version </dev/tty
  if [[ -z "${pyenv_version}" ]]; then
    echo "Version is required to be specified"
    exit 1
  fi

  read -r -p "Choose virtualenvironment name, default '${PWD##*/}': " virtualenv_name </dev/tty
  if [[ -z "${virtualenv_name}" ]]; then
    virtualenv_name="${PWD##*/}"
  fi

  read -r -p "Choose virtualenvironment name prefix, default empty': " virtualenv_name_prefix </dev/tty
  if [[ -z "${virtualenv_name_prefix}" ]]; then
    virtualenv_name_prefix=""
  fi


  echo "${pyenv_version}"
  echo "${virtualenv_name_prefix}${virtualenv_name}"

  python_executable="$(pyenv prefix "${pyenv_version}")/bin/python"

  mkvirtualenv -p "${python_executable}" "${virtualenv_name_prefix}${virtualenv_name}"
}
