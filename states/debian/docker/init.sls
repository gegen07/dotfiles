docker-ppa:
  pkgrepo.managed:
    - humanname: Docker CE PPA
    - name: deb [arch=amd64] https://download.docker.com/linux/ubuntu {{ grains.oscodename }} stable
    - file: /etc/apt/sources.list.d/docker.list
    - keyid: 0EBFCD88
    - key_url: https://download.docker.com/linux/ubuntu/gpg
  
docker.packages:
  pkg.latest:
    - fromrepo: docker-ppa
    - pkgs:
      - docker-ce
      - docker-ce-cli
      - containerd.io

docker-group:
  group.present:
    - group: docker
    - system: True
    - addusers:
      - {{ grains.user }}
