python-packages:
  pkg.installed:
    - pkgs:
      - ca-certificates
      - curl
      - pipx
      - python3
      - python3-dev
      - python3-pip
      - python3-venv

nbdime-install:
  cmd.run:
    - name: pipx install nbdime
    - runas: {{ grains.user }}
    - env:
      - HOME: {{ grains.homedir }}
    - unless: test -x {{ grains.homedir }}/.local/bin/git-nbdiffdriver
    - require:
      - pkg: python-packages
