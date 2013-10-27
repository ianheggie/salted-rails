include :
  - databases.mysql.common

mysql-client:
  pkg.installed:
    - name: {{ "mysql-client" if pillar["versions"]["mysql"] is not defined else "mysql-client-%s" % pillar["versions"]["mysql"] }}

/etc/mysql/conf.d/client-encoding-and-collation.cnf:
  file.managed:
    - user: root
    - group: root
    - mode: 0644
    - source: salt://databases/mysql/client-encoding-and-collation.cnf
    - require:
      - pkg: mysql-client
    - require_in:
      - file: /etc/mysql/conf.d
