load_packages:
  cmd.run:
    - name: dpkg --set-selections < /srv/salt/generated/packages.txt && apt-get -u dselect-upgrade
    - onlyif: test -s /srv/salt/generated/packages.txt

