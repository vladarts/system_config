Всякие полезности для настройки системы
=======================================

PS1 and CLI tools
-----------------

Add to ~/.bashrc or ~/.bash_profile

.. code-block:: sh

    #: VladArts CLI tools
    source ${HOME}/dev/system_config/bashrc/main.sh

Шрифты
------

*    https://github.com/vjpr/monaco-bold - MonacoB 8 для консоли
*    https://github.com/chrissimpkins/Hack - Hack 12 для Pycharm 


Mercurial PS1
-------------

* Compile it with::

    gcc -o fasthgbranch hg-ps1.c
    sudo ln -s $(pwd)/fasthgbranch /usr/bin/

* Use in PS1 with::

	_\$(fasthgbranch)_
