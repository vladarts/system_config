#!/usr/bin/env bash

#: Global definitions
export VP_SYSTEM_CONFIG_ROOT=${VP_SYSTEM_CONFIG_ROOT:-${HOME}/dev/github.com/vladarts/system_config}

#: PS1
source "${VP_SYSTEM_CONFIG_ROOT}/bashrc/ps1_git.sh"
source "${VP_SYSTEM_CONFIG_ROOT}/bashrc/ps1_colors.sh"

#: enable platform-related binaries
case $( uname -s ) in
    Darwin)
        export PATH="${PATH}:${VP_SYSTEM_CONFIG_ROOT}/bin/macos"
        ;;
esac

#: Tools
source "${VP_SYSTEM_CONFIG_ROOT}/bashrc/tools.sh"
