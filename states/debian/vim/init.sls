{% set nvim_version = '0.12.6' %}
{% set pkg_arch = {
  'amd64': 'amd64',
  'x86_64': 'amd64',
  'arm64': 'arm64',
  'aarch64': 'arm64',
}.get(grains.osarch, grains.osarch) %}
{% set nvim_targets = {
  'amd64': {
    'arch': 'x86_64',
    'checksum': '474430d53e6264f6d6dd18db42d6dc9df3a1b56ca9e88a325bbf860e1a811d87',
  },
  'arm64': {
    'arch': 'arm64',
    'checksum': '8f1f64a0bdb97247034038c3823c6cbad5bdf9ecd5751b85494b71c3ee04c815',
  },
} %}
{% set nvim = nvim_targets.get(pkg_arch) %}

neovim-deps:
  pkg.installed:
    - pkgs:
      - ca-certificates
      - curl
      - python3-dev
      - python3-pip
      - python3-pynvim
      - tar
      - universal-ctags

neovim-unstable-ppa:
  pkgrepo.absent:
    - ppa: neovim-ppa/unstable

{% if nvim %}
neovim-install:
  cmd.run:
    - name: |
        set -euo pipefail
        tmp=$(mktemp)
        curl -fsSL -o "$tmp" "https://github.com/neovim/neovim/releases/download/v{{ nvim_version }}/nvim-linux-{{ nvim.arch }}.tar.gz"
        echo "{{ nvim.checksum }}  $tmp" | sha256sum -c -
        rm -rf "/opt/nvim-linux-{{ nvim.arch }}"
        tar -C /opt -xzf "$tmp"
        ln -sfn "/opt/nvim-linux-{{ nvim.arch }}/bin/nvim" /usr/local/bin/nvim
        rm -f "$tmp"
    - shell: /bin/bash
    - unless: /usr/local/bin/nvim --version | head -n 1 | grep -q "NVIM v{{ nvim_version }}"
    - require:
      - pkg: neovim-deps
{% else %}
neovim-unsupported-arch:
  test.fail_without_changes:
    - name: No pinned Neovim build for {{ grains.osarch }}
{% endif %}
