base:
  '*':
    - apt.partner-sources
    - vagrant.minion
    - apt.unwanted
    - www.users
    - sysutils
    - capistrano/deploy_requirements
    - editors.vim
    - sysutils.tmux
{%- if 'app' in pillar['roles'] %}
    - databases.client
    - lang.ruby
    - railsapp
{%- endif %}
{%- if 'web' in pillar['roles'] %}
    - www.nginx
{%- endif %}
{%- if 'db' in pillar['roles'] %}
    - databases
{%- endif %}
{%- if 'gui' in pillar['roles'] %}
    - gui.lxde
    - gui.x2go
    - editors.gvim
    - editors.rubymine
    - www.chromium
{%- endif %}
{%- if 'teamcity' in pillar['roles'] %}
    - ci.teamcity
{%- endif %}
{%- if 'cruisecontrolrb' in pillar['roles'] %}
    - ci.cruisecontrolrb
{%- endif %}
