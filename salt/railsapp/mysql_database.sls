include:
  - databases.mysql.server

database:
  mysql_database.present:
    - names:
      - {{ pillar['database']['development']['database'] }}
      - {{ pillar['database']['test']['database'] }}
    - require:
      - service.running: mysql-server
      - pkg: mysql-server
  mysql_user:
    - present
    - name: {{ pillar['database']['development']['username'] }}
    - password: {{ pillar['database']['development']['password'] }}
    - require:
      - mysql_database.present: database
  mysql_grants.present:
    - database: {{ pillar['database']['development']['username'] }}_%.*
    - grant: ALL PRIVILEGES
    - user: {{ pillar['database']['development']['username'] }}
    - host: localhost
    - require:
      - mysql_user.present: database

