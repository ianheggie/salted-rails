base:
  '*':
    - apt.partner-sources
    - apt.unwanted
    - apt.load_packages
    - vagrant.minion
    - www.users
    - utils
    - crons
    - net.hosts
    - net.ntp
    - net.ufw
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
{%- if 'rubymine' in pillar['versions'] %}
    - editors.rubymine
{%- endif %}
{%- if 'teamcity' in pillar['versions'] %}
    - ci.teamcity
{%- endif %}
{%- if 'cruisecontrolrb' in pillar['roles'] %}
    - ci.cruisecontrolrb
{%- endif %}
