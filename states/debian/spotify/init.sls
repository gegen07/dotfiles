spotify-deps:
  pkg.installed:
    - pkgs:
      - ca-certificates
      - curl
      - gnupg

spotify-keyring:
  cmd.run:
    - name: |
        set -euo pipefail
        install -d -m 0755 /etc/apt/keyrings
        tmp=$(mktemp)
        curl -fsSL -o "$tmp" https://download.spotify.com/debian/pubkey_5384CE82BA52C83A.asc
        gpg --batch --yes --dearmor -o /etc/apt/keyrings/spotify.gpg "$tmp"
        rm -f "$tmp"
        chmod a+r /etc/apt/keyrings/spotify.gpg
    - shell: /bin/bash
    - creates: /etc/apt/keyrings/spotify.gpg
    - require:
      - pkg: spotify-deps

spotify-repo:
  pkgrepo.managed:
    - humanname: Spotify
    - name: "deb [signed-by=/etc/apt/keyrings/spotify.gpg] https://repository.spotify.com stable non-free"
    - file: /etc/apt/sources.list.d/spotify.list
    - aptkey: False
    - require:
      - cmd: spotify-keyring

spotify-install:
  pkg.latest:
    - name: spotify-client
    - refresh: True
    - require:
      - pkgrepo: spotify-repo
