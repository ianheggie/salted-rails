# Optional packages
net:
  pkg.installed:
    - pkgs:
      - traceroute 
      - whois 
      - lynx-cur 
      - wget 
      - curl
{%- if 'gui' in pillar['roles'] %}
      - filezilla
{%- endif %}

