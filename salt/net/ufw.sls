
ufw:
  pkg.installed:
    - pkgs:
      - ufw
{%- if 'gui' in pillar['roles'] %}
      - gufw
{%- endif %}
