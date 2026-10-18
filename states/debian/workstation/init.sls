workstation-mscorefonts-eula:
  debconf.set:
    - name: ttf-mscorefonts-installer
    - data:
        msttcorefonts/accepted-mscorefonts-eula:
          type: boolean
          value: "true"

workstation-packages:
  pkg.installed:
    - pkgs:
      - default-jdk
      - default-jre
      - network-manager-openvpn
      - network-manager-openvpn-gnome
      - openvpn
      - ubuntu-restricted-extras
    - require:
      - debconf: workstation-mscorefonts-eula
