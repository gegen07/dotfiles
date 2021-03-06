include:
  - {{ grains['os_family'] | lower }}: vim

neovim-install-pip:
    {% if grains.os != 'MacOS' %}
    pkg.installed:
      - name: python-pip
    {% else %}
    pkg.installed:
      - name: python3
    {% endif %}

neovim-pip-neovim:
  pip.installed:
    - name: neovim
    {% if grains.os != 'MacOS' %}
    - bin_env: /usr/bin/pip3
    {% else %}
    - bin_env: /usr/local/bin/pip3
    {% endif %}
    - require:
      - pkg: neovim-install-pip

vim-dein-installed?:
  file.exists:
    - name: {{ grains.homedir }}/.dein

vim-install-dein:
  cmd.script:
    - name: https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh
    - args: {{ grains.homedir }}/.dein
    - user: {{ grains.user }}
    - onfail:
      - file: vim-dein-installed?

vim-configuration:
  file.managed:
    - name: {{ grains.homedir }}/.config/nvim/init.vim
    - source: salt://vim/init.vim
    - template: jinja
    - makedirs: True
    - user: {{ grains.user }}
    - group: {{ grains.user }}

