include:
  - apt.partner-sources
  - apt.unwanted
  - lang.ruby
  - www.users
  - www.nginx
  # MySQL
{%- if ('mysql' in pillar['gems']) or ('mysql2' in pillar['gems']) %}
  - databases.mysql
  - databases.phpmyadmin
{%- endif %}
  # PostgreSQL - TODO main alternative to mysql
  # MongoDB - TODO Document database
  # CouchDB - TODO json web distributed db
  # Redis - TODO key value store
  # Riak - TODO Distributed fault tolerant DB
  # RabbitMQ - TODO message broker software
  # Memcached - TODO Memory cache
  # Cassandra - TODO distributed database management system
  # Neo4J - TODO Graph database
  # ElasticSearch - TODO search and analytics engine
  # Kestrel - TODO light-weight persistent message queue
  # SQLite3 - Included by default
  - sysutils
  - develop
  - editors.vim
  - sysutils.tmux
  - railsapp

  #- echo_pillar

# if GUI:
# www.chromium

