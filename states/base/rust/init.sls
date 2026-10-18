{% set rust_version = '1.99.1' %}
{% set rustup_version = '1.29.1' %}
{% set pkg_arch = {
  'amd64': 'amd64',
  'x86_64': 'amd64',
  'arm64': 'arm64',
  'aarch64': 'arm64',
}.get(grains.osarch, grains.osarch) %}
{% set rustup_builds = {
  'amd64': {
    'target': 'x86_64-unknown-linux-gnu',
    'checksum': 'dda7234360b7f578ca8b0ddcb80145646fa61a67c1720a5abc7051b35c9fcb71',
  },
  'arm64': {
    'target': 'aarch64-unknown-linux-gnu',
    'checksum': '15f6e4ce9f583b929c996c91562bad6d4454f3281de858b02cdfdef615fac433',
  },
} %}
{% set rustup = rustup_builds.get(pkg_arch) %}

include:
  - {{ grains['os_family'] | lower }}: rust

{% if rustup %}
rust-install:
  cmd.run:
    - name: |
        set -euo pipefail
        tmp=$(mktemp)
        curl -fsSL -o "$tmp" "https://static.rust-lang.org/rustup/archive/{{ rustup_version }}/{{ rustup.target }}/rustup-init"
        echo "{{ rustup.checksum }}  $tmp" | sha256sum -c -
        chmod +x "$tmp"
        "$tmp" -y --no-modify-path --profile default --default-toolchain {{ rust_version }}
        rm -f "$tmp"
    - shell: /bin/bash
    - runas: {{ grains.user }}
    - env:
      - HOME: {{ grains.homedir }}
      - CARGO_HOME: {{ grains.homedir }}/.cargo
      - RUSTUP_HOME: {{ grains.homedir }}/.rustup
    - unless: {{ grains.homedir }}/.cargo/bin/rustc --version | grep -q 'rustc {{ rust_version }} '
    - require:
      - pkg: rust-deps
{% else %}
rust-unsupported-arch:
  test.fail_without_changes:
    - name: No Rust {{ rust_version }} build for {{ grains.osarch }}
{% endif %}
