include:
  - databases.mysql.client

/etc/mysql/debian.cnf:
  file.managed:
    - user: root
    - group: root
    - mode: 0600
    - replace: False
    - require:
      - pkg: mysql-server
    - require_in:
      - file: /etc/mysql

/etc/mysql/debian-start:
  file.managed:
    - user: root
    - group: root
    - mode: 0755
    - replace: False
    - require:
      - pkg: mysql-server
    - require_in:
      - file: /etc/mysql

/etc/mysql/conf.d/server-encoding-and-collation.cnf:
  file.managed:
    - user: root
    - group: root
    - mode: 0644
    - source: salt://databases/mysql/server-encoding-and-collation.cnf
    - require:
      - pkg: mysql-server
    - watch_in:
      - service: mysql-server
    - require_in:
      - file: /etc/mysql/conf.d

/etc/mysql/conf.d/default-table-engine.cnf:
  file.managed:
    - user: root
    - group: root
    - mode: 0644
    - source: salt://databases/mysql/default-table-engine.cnf
    - require:
      - pkg: mysql-server
    - watch_in:
      - service: mysql-server
    - require_in:
      - file: /etc/mysql/conf.d

mysql-server:
  pkg.installed:
    - name: {{ "mysql-server" if pillar["versions"]["mysql"] is not defined else "mysql-server-%s" % pillar["versions"]["mysql"] }}
  service.running:
    - name: mysql
    - require:
      - pkg: mysql-server
      - pkg: mysql-client
