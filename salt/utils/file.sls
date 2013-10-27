# Optional packages
file:
  pkg.installed:
    - pkgs:
      - gzip 
      - unzip 
      - saidar 
      - less
      - meld
      - p7zip
      - p7zip-full
{%- if 'gui' in pillar['roles'] %}
      - pinta
{%- endif %}
      - unrar-free
      # Available only in later ubuntu releases?
      #- p7zip-rar
      #- rar
      #- unrar
