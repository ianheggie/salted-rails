salt_packages:
  pkg.installed:
    - pkgs:
      - openssl
      - python-openssl
      - python-mysqldb
      - apache2-utils

