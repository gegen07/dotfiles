{% set go_version = '1.27.2' %}
{% set go_release = 'go' ~ go_version %}
{% set pkg_arch = {
  'amd64': 'amd64',
  'x86_64': 'amd64',
  'arm64': 'arm64',
  'aarch64': 'arm64',
}.get(grains.osarch, grains.osarch) %}
{% set go_checksums = {
  'amd64': 'ecbadb99091a3f46e31f5f934b068b1864eafa7995211b39eaddf76996045fe5',
  'arm64': '94f3e30b8e374bc285e7dadc11e0865726b9bc6e85b841ccceaabc0214c6b7c8',
} %}

include:
  - {{ grains['os_family'] | lower }}: golang

golang-directory:
  file.directory:
    - name: {{ grains.homedir }}/dev/projects/gocode
    - user: {{ grains.user }}
    - makedirs: True

{% if pkg_arch in go_checksums %}
golang-install:
  cmd.run:
    - name: |
        set -euo pipefail
        tmp=$(mktemp)
        curl -fsSL -o "$tmp" "https://go.dev/dl/{{ go_release }}.linux-{{ pkg_arch }}.tar.gz"
        echo "{{ go_checksums[pkg_arch] }}  $tmp" | sha256sum -c -
        rm -rf /usr/local/go
        tar -C /usr/local -xzf "$tmp"
        rm -f "$tmp"
    - shell: /bin/bash
    - unless: test -f /usr/local/go/VERSION && grep -qx "{{ go_release }}" /usr/local/go/VERSION
    - require:
      - pkg: golang-dep
{% else %}
golang-unsupported-arch:
  test.fail_without_changes:
    - name: No Go {{ go_release }} checksum for {{ grains.osarch }}
{% endif %}
