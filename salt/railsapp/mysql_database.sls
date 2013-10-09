include:
  - databases.mysql.server

{%- if ('development' in pillar['databases']) %}

database:
  mysql_database.present:
    - names:
      - {{ pillar['databases']['development']['database'] }}
{%- if ('test' in pillar['databases']) %}
      - {{ pillar['databases']['test']['database'] }}
{%- endif %}
    - require:
      - service.running: mysql-server
      - pkg: mysql-server
  mysql_user:
    - present
    - name: {{ pillar['databases']['development']['username'] }}
    - password: {{ pillar['databases']['development']['password'] }}
    - require:
      - mysql_database.present: database
  mysql_grants.present:
    - database: {{ pillar['databases']['development']['username'] }}_%.*
    - grant: ALL PRIVILEGES
    - user: {{ pillar['databases']['development']['username'] }}
    - host: localhost
    - require:
      - mysql_user.present: database

{%- endif %}
