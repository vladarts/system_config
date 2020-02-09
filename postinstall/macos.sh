#!/usr/bin/env bash

#: brew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

#: Completion
brew install bash-completion
brew tap homebrew/completions

#: Required software
brew install git python@2 python@3 mc nano pyenv watch htop curl

#: python virtualenvwrapper
pip3 install virtualenv virtualenvwrapper

#: Clone config repository
mkdir ${HOME}/dev
git clone git@github.com:xxxbobrxxx/system_config.git ${HOME}/dev/system_config

#: bash_profile
rm -f ${HOME}/.bash_profile
cp ${HOME}/dev/system_config/bashrc/macos_bash_profile.sh ${HOME}/.bash_profile

#: Global ignore file
git config --global core.excludesfile ${HOME}/dev/system_config/bashrc/ignore


#: Google Chrome color fix
while true; do
    read -p "Install Google Chrome Mojave theme fix? [Y/n] " yn </dev/tty
    case ${yn} in
        [Yy]* )
            defaults write org.chromium.Chromium NSRequiresAquaSystemAppearance -bool Yes
            defaults write com.google.Chrome NSRequiresAquaSystemAppearance -bool Yes

            break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no!";;
    esac
done

#: Mojave fonts fix
while true; do
    read -p "Install Mojave antialiasing font fix? [Y/n] " yn </dev/tty
    case ${yn} in
        [Yy]* )
            defaults write -g CGFontRenderingFontSmoothingDisabled -bool NO

            break;;
        [Nn]* )
            echo """Use

$ defaults write -g CGFontRenderingFontSmoothingDisabled -bool NO

For manual installation
"""
            break;;
        * ) echo "Please answer yes or no!";;
    esac
done

#: gsutil
while true; do
    read -p "Install gsutil? [Y/n] " yn </dev/tty
    case ${yn} in
        [Yy]* )
            curl https://sdk.cloud.google.com | bash

            break;;
        [Nn]* )
            echo """Use

$ curl https://sdk.cloud.google.com | bash

For manual installation
"""

            break;;
        * ) echo "Please answer yes or no!";;
    esac
done

#: sdkman
while true; do
    read -p "Install sdkman? [Y/n] " yn </dev/tty
    case ${yn} in
        [Yy]* )
            curl -s get.sdkman.io | bash

            break;;
        [Nn]* )
            echo """Use

$ curl -s get.sdkman.io | bash

For manual installation
"""

            break;;
        * ) echo "Please answer yes or no!";;
    esac
done

echo 'Install java by executing /usr/libexec/java_home command'
