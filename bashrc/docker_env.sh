#!/bin/bash
# 
# This snippet helps manage many different docker environments with tls
# 
# Requirements:
# 	1. Directory to store environments
# 	2. Each env should be placed in own directory
# 	3. Name of directory should match <host>:<port> pattern
# 
# Directories tree example:
# 	~/.docker/host1:1337
# 	~/.docker/host2:1337
# 	~/.docker/host3:1337
# 
# Usage example:
# 	activate_docker_env host1:1337
# 	deactivate_docker_env
# 
# Installation:
# 	add `source <path/to/this/file.sh>` to ~/.bashrc or ~/.bash_profile

DOCKER_ENVS_DIR=${DOCKER_ENVS_DIR:-${HOME}/.docker}


deactivate_docker_env() {
	unset DOCKER_HOST; 
	unset DOCKER_TLS_VERIFY;
	unset DOCKER_CERT_PATH;
}

activate_docker_env() {
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
