{% set account_group = grains.get('group', grains.user) %}

include:
  - {{ grains['os_family'] | lower }}: vim

{{ grains.homedir }}/.dein:
  file.directory:
    - user: {{ grains.user }}
    - group: {{ account_group }}
    - mode: 755
    - makedirs: True
    - require:
      - pkg: neovim-deps

vim-install-dein:
  cmd.script:
    - source: https://raw.githubusercontent.com/Shougo/dein.vim/3.1/bin/installer.sh
    - args: {{ grains.homedir }}/.dein
    - user: {{ grains.user }}
    - unless: test -d {{ grains.homedir }}/.dein/repos/github.com/Shougo/dein.vim
    - require:
      - file: {{ grains.homedir }}/.dein

vim-configuration:
  file.managed:
    - name: {{ grains.homedir }}/.config/nvim/init.vim
    - source: salt://vim/init.vim
    - template: jinja
    - makedirs: True
    - user: {{ grains.user }}
    - group: {{ account_group }}
