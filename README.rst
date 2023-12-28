System configuration
====================

PS1 and CLI tools
-----------------

Clone the repo:

.. code-block:: bash

  mkdir -p ${HOME}/dev/github.com/vladarts/system_config
  git clone https://github.com/vladarts/system_config ${HOME}/dev/github.com/vladarts/system_config

Add to ~/.bashrc or ~/.bash_profile

.. code-block:: sh

  #: CLI tools
  source ${HOME}/dev/github.com/vladarts/system_config/bashrc/main.sh

Fonts
-----

- https://github.com/vjpr/monaco-bold - MonacoB 8 для консоли
- https://github.com/chrissimpkins/Hack - Hack 12 для Pycharm

Mercurial PS1
-------------

* Compile it with:

.. code-block:: bash

  gcc -o fasthgbranch hg-ps1.c
  sudo ln -s $(pwd)/fasthgbranch /usr/bin/

* Use in PS1 with:

.. code-block:: bash

  _\$(fasthgbranch)_
