zsh-install:
  pkg.installed:
    - name: zsh
zsh-config-aliases:
  file.symlink:
    - name: {{ grains.homedir }}/.zaliases
    - target: {{ grains.stateroot }}/base/zsh/config/aliases
    - user: {{ grains.user }}
    - force: True
zsh-config-env:
  file.symlink:
    - name: {{ grains.homedir }}/.zshenv
    - target: {{ grains.stateroot }}/base/zsh/config/env
    - user: {{ grains.user }}
    - force: True
zsh-config-rc:
  file.symlink:
    - name: {{ grains.homedir }}/.zshrc
    - target: {{ grains.stateroot }}/base/zsh/config/rc
    - user: {{ grains.user }}
    - force: True
