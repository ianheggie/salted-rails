
include:
  # MySQL
{%- if ('mysql' in pillar['gems']) or ('mysql2' in pillar['gems']) %}
  - databases.mysql.server
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
