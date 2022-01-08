#!/usr/bin/env bash

VP_PYTHON="${HOME}/.virtualenvs/vp/bin/python3"

vp.python.setup_virtualenv() {
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

vp.idea.gen_project() {
  # shellcheck disable=SC2068
  ${VP_PYTHON} "${VP_SYSTEM_CONFIG_ROOT}/bin/gen_idea_project.py" $@
}

#:
#: This snippet helps manage many different docker environments with tls
#:
#: Requirements:
#: 	1. Directory to store environments
#: 	2. Each env should be placed in own directory
#: 	3. Name of directory should match <host>:<port> pattern
#:
#: Directories tree example:
#: 	~/.docker/host1:1337
#: 	~/.docker/host2:1337
#: 	~/.docker/host3:1337
#:
#: Usage example:
#: 	vp.docker.activate_env host1:1337
#: 	vp.docker.activate_env
#:
DOCKER_ENVS_DIR=${DOCKER_ENVS_DIR:-${HOME}/.docker}

vp.docker.deactivate_env() {
	unset DOCKER_HOST;
	unset DOCKER_TLS_VERIFY;
	unset DOCKER_CERT_PATH;
}

vp.docker.activate_env() {
	if [ -d "${DOCKER_ENVS_DIR}/$1" ]; then
		export DOCKER_HOST="$1"
		export DOCKER_TLS_VERIFY=1
		export DOCKER_CERT_PATH=${DOCKER_ENVS_DIR}/$1
	else
		echo 'Docker enfironment does not exists' 1>&2
		return 1
	fi
}

_complete_activate_docker_env() {
	local cur="${COMP_WORDS[COMP_CWORD]}"

	COMPREPLY=( $( compgen -W "$(ls -d ${DOCKER_ENVS_DIR}/*/|cut -d "/" -f 5)" -- ${cur} ) )
}
complete -F _complete_activate_docker_env activate_docker_env
