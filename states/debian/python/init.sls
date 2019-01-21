python27-installer:
  pkg.installed:
    - pkgs:
      - python2.7
      - python2.7-dev
      - python-pip

python36-installer:
  pkg.installed:
    - pkgs:
      - python3.6
      - python3.6-dev
      - python3.6-venv
      - python3-pip
