#: Global definitions
export VA_SYSTEM_CONFIG_ROOT=${VA_SYSTEM_CONFIG_ROOT:-${HOME}/dev/system_config}

#: PS1
source "${VA_SYSTEM_CONFIG_ROOT}/bashrc/ps1_git.sh"
source "${VA_SYSTEM_CONFIG_ROOT}/bashrc/ps1_colors.sh"

#: Docker environment manager
source "${VA_SYSTEM_CONFIG_ROOT}/bashrc/docker_env.sh"
