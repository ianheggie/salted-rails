
databases-packages:
  pkg.installed:
    - pkgs:
{%- if ('mysql' in pillar['roles']) %}
      - libmysqlclient-dev
{%- endif %}
{%- if ('postgresql' in pillar['roles']) %}
      - libpq-dev
{%- endif %}

# TODO: when I need them:

#{%- if ('memcached' in pillar['roles']) %}
#  # Memcached - TODO Memory cache
#{%- endif %}

#{%- if ('mongodb' in pillar['roles']) %}
#  # MongoDB - TODO Document database
#{%- endif %}
#{%- if ('couchdb' in pillar['roles']) %}
#  # CouchDB - TODO json web distributed db
#{%- endif %}
#{%- if ('redis' in pillar['roles']) %}
#  # Redis - TODO key value store
#{%- endif %}
#{%- if ('riak' in pillar['roles']) %}
#  # Riak - TODO Distributed fault tolerant DB
#{%- endif %}
#{%- if ('rabbitmq' in pillar['roles']) %}
#  # RabbitMQ - TODO message broker software
#{%- endif %}
#{%- if ('cassandra' in pillar['roles']) %}
#  # Cassandra - TODO distributed database management system
#{%- endif %}
#{%- if ('neo4j' in pillar['roles']) %}
#  # Neo4J - TODO Graph database
#{%- endif %}
#{%- if ('elasticsearch' in pillar['roles']) %}
#  # ElasticSearch - TODO search and analytics engine
#{%- endif %}
#{%- if ('kestrel' in pillar['roles']) %}
#  # Kestrel - TODO light-weight persistent message queue
#{%- endif %}
#{%- if ('sqllite3' in pillar['roles']) %}
#  # SQLite3 - Included by default
#{%- endif %}
