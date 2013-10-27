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

# vim: filetype=sls:
