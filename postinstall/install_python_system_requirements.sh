#!/usr/bin/env bash
# Установка системных зависимостей


case $( uname -s ) in
    Linux)
        if which yum; then
            sudo yum -y groupinstall 'Development Tools'
            sudo yum -y install git uwsgi libxml2-devel libxslt-devel libffi-devel blas-devel lapack-devel \
                uwsgi-plugin-common uwsgi-plugin-python uwsgi-devel zlib-devel uuid-devel uuid-c++-devel \
                libuuid libuuid-devel libuuid libuuid-devel libcap-devel openssl openssl-devel yum-utils \
                net-tools nano bzip2-devel freetype-devel libpng-devel readline-devel sqlite-devel \
                hdf5-devel jemalloc-devel postgresql-devel python-pip
        elif which apt-get; then
            sudo apt-get install git libxml2-dev libxslt-dev libffi-dev libblas-dev liblapack-dev zlib1g-dev uuid-dev \
                libcap-dev openssl net-tools nano bzip2 libfreetype6-dev libbz2-dev libpng-dev libreadline-dev \
                sqlite-dev libhdf5-dev jemalloc-dev postgresql-server-dev-all python-pip libsqlite3-dev
        else
            echo "[ERROR] Only yum or apt-get supported on Linux platform"
            exit 1
        fi

        sudo pip install -U pip

        # Устанавливаем глобально virtualenvwrapper
        sudo pip install virtualenv virtualenvwrapper;;
    Darwin)
        echo "[WARNING] You must launch this script 2 times if Developers Tools not installed"
        if which brew; then
            # TODO: Добавить зависимости для mac
            xcode-select --install
            brew install coreutils
            brew install python
            brew install homebrew/science/hdf5
            brew install gcc
        else
            echo "[ERROR] brew is not installed"
        fi

        pip install -U pip

        # Устанавливаем глобально virtualenvwrapper
        pip install virtualenv virtualenvwrapper;;
    *)
        echo "[ERROR] Your system is not supported"
        exit 1;;
esac
