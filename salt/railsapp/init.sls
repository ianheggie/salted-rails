include:
  - railsapp.packages
  - railsapp.gems
{%- if ('mysql' in pillar['gems']) or ('mysql2' in pillar['gems']) %}
  - railsapp.mysql_database
{%- endif %}
