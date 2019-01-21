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
