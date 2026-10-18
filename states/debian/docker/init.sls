{% set pkg_arch = {
  'amd64': 'amd64',
  'x86_64': 'amd64',
  'arm64': 'arm64',
  'aarch64': 'arm64',
  'armhf': 'armhf',
}.get(grains.osarch, grains.osarch) %}

docker-deps:
  pkg.installed:
    - pkgs:
      - ca-certificates
      - curl

docker-keyring:
  cmd.run:
    - name: |
        set -euo pipefail
        install -m 0755 -d /etc/apt/keyrings
        curl -fsSL -o /etc/apt/keyrings/docker.asc https://download.docker.com/linux/ubuntu/gpg
        chmod a+r /etc/apt/keyrings/docker.asc
    - shell: /bin/bash
    - creates: /etc/apt/keyrings/docker.asc
    - require:
      - pkg: docker-deps

docker-repo:
  pkgrepo.managed:
    - humanname: Docker CE
    - name: "deb [arch={{ pkg_arch }} signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu {{ grains.oscodename }} stable"
    - file: /etc/apt/sources.list.d/docker.list
    - aptkey: False
    - require:
      - cmd: docker-keyring

docker-packages:
  pkg.latest:
    - refresh: True
    - pkgs:
      - containerd.io
      - docker-buildx-plugin
      - docker-ce
      - docker-ce-cli
      - docker-compose-plugin
    - require:
      - pkgrepo: docker-repo

docker-group:
  group.present:
    - name: docker
    - system: True
    - addusers:
      - {{ grains.user }}
    - require:
      - pkg: docker-packages
