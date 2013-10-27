include:
  - databases.packages
  - railsapp.packages
{%- if ('app' in pillar['roles']) %}
{%- if 'ruby' in pillar['versions'] %}
  - railsapp.gems
{%- endif %}
{%- endif %}
{%- if ('mysql' in pillar['roles']) %}
  - railsapp.mysql_database
{%- endif %}
