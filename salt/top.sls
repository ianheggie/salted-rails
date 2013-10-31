base:
  '*':
    - apt.partner-sources
    - apt.unwanted
    - apt.load_packages
    - apt.dist_upgrade
    - apt.salt_packages
    - vagrant.minion
    - www.users
    - utils
    - crons
    - net.hosts
    - net.ntp
    - scm
    - editors.vim
    - lang.ruby
{%- if ('ruby' in pillar['versions']) %}
    - lang.rbenv
    - railsapp
{%- endif %}
    - lang.php
{%- if ('php' in pillar['versions']) %}
    - lang.phpenv
{%- endif %}
    #- lang.java # - require if we load jenv or java programs 
{%- if ('java' in pillar['versions']) %}
    - lang.jenv
{%- endif %}
{%- if 'web' in pillar['roles'] %}
    - www.nginx
{%- endif %}
{%- if 'db' in pillar['roles'] %}
    - databases
{%- endif %}
{%- if 'gui' in pillar['roles'] %}
    # lxde
    - gui.desktop
    - gui.x2go
    - editors.gvim
    - www.chromium
{%- endif %}
{%- if 'rubymine' in pillar['roles'] %}
    - editors.rubymine
{%- endif %}
{%- if 'teamcity' in pillar['roles'] %}
    - ci.teamcity
{%- endif %}
{%- if 'cruisecontrolrb' in pillar['roles'] %}
    - ci.cruisecontrolrb
{%- endif %}
{%- if 'secure' in pillar['roles'] %}
    - net.ufw
    #TODO: net.fail2ban
{%- endif %}
{%- if 'monitored' in pillar['roles'] %}
    #TODO: - server.monit
    #TODO: - server.munin
{%- endif %}

# # cookbook 'ack' ?

