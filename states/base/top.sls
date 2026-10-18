base:
  'roles:core':
    - match: grain
    - git
    - vim
    - zsh
  'roles:dev':
    - match: grain
    - dev-tools
    - docker
    - golang
    - python
    - rust
    - vscode
  'roles:desktop':
    - match: grain
    - chrome
    - discord
    - spotify
    - workstation
