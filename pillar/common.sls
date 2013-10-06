{%- if grains['os'] == 'MacOS' %}
etc_dir: /opt/local/etc/
var_dir: /opt/local/var/
logs_dir: /opt/local/var/log/
{%- else %}
etc_dir: /etc/
var_dir: /var/
logs_dir: /var/log/
{%- endif %}

www_dir: /srv/www/

mysql-version: 5.5

teamcity-version: 8.0.4

rubymine-version: 5.4.3


# vim: filetype=sls
