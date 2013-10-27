
mercurial:
  pkg.installed:
    - pkgs:
      - mercurial
      - mercurial-git
{%- if 'gui' in pillar['roles'] %}
      - qct
      - hgview
{%- endif %}
