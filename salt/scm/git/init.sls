git:
  pkg.installed:
    - pkgs:
      - git
{%- if 'gui' in pillar['roles'] %}
      - git-gui
      - gitk
      - qgit
{%- endif %}
  file.managed:
    - source: salt://scm/git/gitconfig
    - name: {{ pillar['homedir'] }}/.gitconfig
    - user: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    - template: jinja
    - replace: false
    - mode: 644
    - require:
      - pkg: git

# consider git-web, but may need to force www.nginx to make sure apache doesnt get loaded
