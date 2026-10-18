{% set pkg_arch = {
  'amd64': 'amd64',
  'x86_64': 'amd64',
}.get(grains.osarch) %}

{% if pkg_arch == 'amd64' %}
google-chrome-deps:
  pkg.installed:
    - pkgs:
      - ca-certificates
      - curl
      - gnupg

google-chrome-keyring:
  cmd.run:
    - name: |
        set -euo pipefail
        install -d -m 0755 /etc/apt/keyrings
        tmp=$(mktemp)
        curl -fsSL -o "$tmp" https://dl.google.com/linux/linux_signing_key.pub
        gpg --batch --yes --dearmor -o /etc/apt/keyrings/google-chrome.gpg "$tmp"
        rm -f "$tmp"
        chmod a+r /etc/apt/keyrings/google-chrome.gpg
    - shell: /bin/bash
    - creates: /etc/apt/keyrings/google-chrome.gpg
    - require:
      - pkg: google-chrome-deps

google-chrome-repo:
  pkgrepo.managed:
    - humanname: Google Chrome
    - name: "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] https://dl.google.com/linux/chrome/deb/ stable main"
    - file: /etc/apt/sources.list.d/google-chrome.list
    - aptkey: False
    - require:
      - cmd: google-chrome-keyring

google-chrome-install:
  pkg.latest:
    - name: google-chrome-stable
    - refresh: True
    - require:
      - pkgrepo: google-chrome-repo
{% else %}
google-chrome-unsupported:
  test.succeed_without_changes:
    - name: Google Chrome apt packages are published for amd64 only
{% endif %}
