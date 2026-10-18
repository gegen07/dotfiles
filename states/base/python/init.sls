{% set account_group = grains.get('group', grains.user) %}
{% set micromamba_version = '2.9.0' %}
{% set micromamba_tag = '2.9.0-0' %}
{% set pkg_arch = {
  'amd64': 'amd64',
  'x86_64': 'amd64',
  'arm64': 'arm64',
  'aarch64': 'arm64',
}.get(grains.osarch, grains.osarch) %}
{% set micromamba_builds = {
  'amd64': {
    'asset': 'micromamba-linux-64',
    'checksum': '366cd9cd8be14df1ab8ed50352a82111082a36686b2d389fdb79a92c3fafb3e3',
  },
  'arm64': {
    'asset': 'micromamba-linux-aarch64',
    'checksum': '9f93b974adcb4d166996af969b6cd371287d1a3e52733704727884d9b74cb7a7',
  },
} %}
{% set micromamba = micromamba_builds.get(pkg_arch) %}

include:
  - {{ grains['os_family'] | lower }}: python

micromamba-bin-dir:
  file.directory:
    - name: {{ grains.homedir }}/.local/bin
    - user: {{ grains.user }}
    - group: {{ account_group }}
    - mode: 755
    - makedirs: True

micromamba-root:
  file.directory:
    - name: {{ grains.homedir }}/micromamba
    - user: {{ grains.user }}
    - group: {{ account_group }}
    - mode: 755
    - makedirs: True

{% if micromamba %}
micromamba-install:
  cmd.run:
    - name: |
        set -euo pipefail
        tmp=$(mktemp)
        curl -fsSL -o "$tmp" "https://github.com/mamba-org/micromamba-releases/releases/download/{{ micromamba_tag }}/{{ micromamba.asset }}"
        echo "{{ micromamba.checksum }}  $tmp" | sha256sum -c -
        install -m 755 "$tmp" "{{ grains.homedir }}/.local/bin/micromamba"
        rm -f "$tmp"
    - shell: /bin/bash
    - runas: {{ grains.user }}
    - unless: {{ grains.homedir }}/.local/bin/micromamba --version | grep -qx '{{ micromamba_version }}'
    - require:
      - file: micromamba-bin-dir
      - pkg: python-packages
{% else %}
micromamba-unsupported-arch:
  test.fail_without_changes:
    - name: No micromamba {{ micromamba_version }} build for {{ grains.osarch }}
{% endif %}
