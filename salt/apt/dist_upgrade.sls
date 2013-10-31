upgrade_packages:
  cmd.run:
    - name: env DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade
    - unless: test -s /srv/salt/generated/packages.txt

