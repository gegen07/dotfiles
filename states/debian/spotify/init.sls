spotify-ppa:
  pkgrepo.managed:
   - humanname: Spotify
   - name: deb http://repository.spotify.com stable non-free
   - file: /etc/apt/sources.list.d/spotify.list
   - key_url: https://download.spotify.com/debian/pubkey_5E3C45D7B312C643.gpg

spotify-install:
  pkg.latest:
    - require:
      - pkgrepo: spotify-ppa
    - name: spotify-client
    - skip_verify: True
    - refresh: True
