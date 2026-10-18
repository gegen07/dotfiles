{% set account_group = grains.get('group', grains.user) %}

git-install:
  pkg.installed:
    - pkgs:
      - git

git-config:
  file.symlink:
    - name: {{ grains.homedir }}/.gitconfig
    - target: {{ grains.stateroot }}/base/git/gitconfig
    - user: {{ grains.user }}
    - force: True

git-ignore-dir:
  file.directory:
    - name: {{ grains.homedir }}/.config/git
    - user: {{ grains.user }}
    - group: {{ account_group }}
    - mode: 755
    - makedirs: True

git-ignore:
  file.symlink:
    - name: {{ grains.homedir }}/.config/git/ignore
    - target: {{ grains.stateroot }}/base/git/ignore
    - user: {{ grains.user }}
    - force: True
    - require:
      - file: git-ignore-dir
