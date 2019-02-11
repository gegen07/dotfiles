{% set golang_version = 'go1.11.2' %}
{% set golang_distribution = 'linux' %}

include:
  - {{ grains['os_family'] | lower }}: golang

golang-directory:
  file.directory:
    - name: {{ grains.homedir }}/dev/gocode
    - user: {{ grains.user }}
    - makedirs: True

golang-install:
  cmd.run:
    - cwd: /usr/local
    - name: curl https://dl.google.com/go/{{ golang_version }}.{{ golang_distribution }}-amd64.tar.gz | tar xz
    - unless: test -d /usr/local/bin && grep -q "{{ golang_version }}" /usr/local/go/VERSION
    - user: root
    - require:
      - golang-dep
