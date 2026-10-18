vscode-deps:
  pkg.installed:
    - pkgs:
      - ca-certificates
      - curl
      - gnupg

vscode-keyring:
  cmd.run:
    - name: |
        set -euo pipefail
        install -d -m 0755 /usr/share/keyrings
        tmp=$(mktemp)
        curl -fsSL -o "$tmp" https://packages.microsoft.com/keys/microsoft.asc
        gpg --batch --yes --dearmor -o /usr/share/keyrings/microsoft.gpg "$tmp"
        rm -f "$tmp"
        chmod a+r /usr/share/keyrings/microsoft.gpg
    - shell: /bin/bash
    - creates: /usr/share/keyrings/microsoft.gpg
    - require:
      - pkg: vscode-deps

vscode-repo:
  pkgrepo.managed:
    - humanname: Visual Studio Code
    - name: "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main"
    - file: /etc/apt/sources.list.d/vscode.list
    - aptkey: False
    - require:
      - cmd: vscode-keyring

vscode-old-sources:
  file.absent:
    - name: /etc/apt/sources.list.d/vscode.sources

vscode-install:
  pkg.latest:
    - name: code
    - refresh: True
    - require:
      - pkgrepo: vscode-repo
      - file: vscode-old-sources
