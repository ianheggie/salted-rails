
ufw:
  pkg.installed:
    - pkgs:
      - ufw
{%- if 'gui' in pillar['roles'] %}
      - gufw
{%- endif %}
  cmd.run:
    - name: ufw limit ssh ; ufw --force enable
    - requires:
      - pkg: ufw
