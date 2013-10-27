
bazaar:
  pkg.installed:
    - pkgs:
      - bzr
      - bzrtools
{%- if 'gui' in pillar['roles'] %}
      - qbzr
      - bzr-explorer
{%- endif %}
