packages:
  pkg.installed:
    - pkgs:
      # For Asset Pipeline (compression of files)
      - nodejs
      # MySQL
{%- if ('mysql' in pillar['gems']) or ('mysql2' in pillar['gems']) %}
      - libmysqlclient-dev 
{%- endif %}
      # PostgreSQL
{%- if 'pg' in pillar['gems'] %}
      - libpq-dev
{%- endif %}
      # SQLite3 - Already installed
      # COMMON PACKAGES:
{%- if 'rmagick' in pillar['gems'] %}
      - imagemagick
      - libmagickwand-dev
      - ghostscript
{%- endif %}
      # Memcached
{%- if ('memcache' in pillar['gems']) or ('dalli' in pillar['gems']) %}
      - memcached
{%- endif %}
{%- if 'capybara-webkit' in pillar['gems'] %}
      # Note - this sucks in 254 MB of additional disk space just to stop it complaining
      # AND it should used in gui (so you will other things to load)
      - libqt4-dev
      - libgtk2.0-dev
      - libgtkmm-3.0
      - libnotify-bin
{%- endif %}
{%- if 'thinking-sphinx' in pillar['gems'] %}
      - sphinxsearch
{%- endif %}
      # Other databases mentioned by travis-ci
      # MongoDB
      # CouchDB
      # Redis
      # Riak
      # RabbitMQ
      # Cassandra
      # Neo4J
      # ElasticSearch
      # Kestrel
