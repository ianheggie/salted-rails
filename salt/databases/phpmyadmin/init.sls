include:
  - www.users
  - www.nginx
  - lang.php

phpmyadmin:
  pkg.installed:
    - name: phpmyadmin

phpmyadmin_nginx:
  file.managed:
    - source: salt://databases/phpmyadmin/etc/nginx/admin.d/phpmyadmin.conf
    - name: {{ pillar['etc_dir'] }}nginx/admin.d/phpmyadmin.conf
    - user: root
    - group: root
    - template: jinja
    - mode: 644

