load_packages:
  cmd.run:
    - name: dpkg --set-selections < /srv/salt/generated/packages.txt && env DEBIAN_FRONTEND=noninteractive apt-get -y -u dselect-upgrade
    - onlyif: test -s /srv/salt/generated/packages.txt

