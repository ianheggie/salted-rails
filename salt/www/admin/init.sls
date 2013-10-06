nginx:
  pkg.installed:
    - name: nginx-full
  service:
    - running
    - enable: True
    - reload: True
    - watch:
      #- file: {{ pillar['etc_dir'] }}nginx/nginx.conf
      #- file: {{ pillar['etc_dir'] }}nginx/sites-enabled/*
      - file: {{ pillar['etc_dir'] }}nginx/*
  require:
    - file: {{ pillar['etc_dir'] }}nginx/nginx.conf

admin-site:
  file.managed:
    - source: salt://www/nginx/etc/nginx/admin.d/phpmyadmin.conf
    - name: {{ pillar['etc_dir'] }}nginx/admin.d/phpmyadmin.conf
    - user: root
    - group: root
    - template: jinja
    - mode: 644

admin_conf:

#{{ pillar['etc_dir'] }}nginx/nginx.conf:
#  file.managed:
#    - source: salt://www/nginx/etc/nginx/nginx.conf
#    - user: root
#    - group: root
#    - mode: 644
