nginx:
  pkg.installed:
    - pkgs:
      - nginx-full
      - apache2-utils   # for htpasswd
  service:
    - running
    - enable: True
    - reload: True
    - watch:
      - file: enable-admin-site
    - require:
      - file.directory: admin-d
      - pkg: nginx

www_dir:
  file.directory:
    - name: {{ pillar['www_dir'] }}
    - user: root
    - group: root
    - mode: 775
    - makedirs: True

admin-d:
  file.recurse:
    - source: salt://www/nginx/etc/nginx/admin.d
    - name: {{ pillar['etc_dir'] }}/nginx/admin.d
    - user: root
    - group: root
    - file_mode: 644
    - dir_mode: 755
    - exclude_pat: '.*swp'
    - require:
      - pkg: nginx

admin-conf:
  module.run:
    - name: tls.create_self_signed_cert
    - tls_dir: 'self_signed'
    - emailAddress: "webmaster@{{ pillar['domain'] }}"
    - require:
      - file: admin-d
  file.managed:
    - source: salt://www/nginx/etc/nginx/sites-available/admin.conf
    - name: {{ pillar['etc_dir'] }}/nginx/sites-available/admin.conf
    - user: root
    - group: root
    - template: jinja
    - mode: 644
    - require:
      - module: admin-conf

admin-site-templated:
  file.recurse:
    - source: salt://www/nginx/srv/www/admin
    - name: {{ pillar['www_dir'] }}/admin
    - user: root
    - group: root
    - template: jinja
    - include_pat: '*.php'
    - file_mode: 644
    - dir_mode: 755

admin-site-raw:
  file.recurse:
    - source: salt://www/nginx/srv/www/admin
    - name: {{ pillar['www_dir'] }}/admin
    - user: root
    - group: root
    - exclude_pat: '*.php'
    - file_mode: 644
    - dir_mode: 755

enable-admin-site:
  file.symlink:
    - target: {{ pillar['etc_dir'] }}nginx/sites-available/admin.conf
    - name: {{ pillar['etc_dir'] }}/nginx/sites-enabled/admin.conf
    - require:
      - file: admin-conf

{{ pillar['etc_dir'] }}/nginx/admin.d/htpasswd:
  file.managed:
    - contents: "#users that are allowed to access admin website\n"
    - replace: False
    - require:
      - file: admin-d

{{ pillar['etc_dir'] }}/nginx/staging_passwd:
  file.managed:
    - contents: "#users that are allowed to access staging website\n"
    - replace: False
    - require:
      - file: admin-d

{%- if pillar['admin_password'] %}

admin-user:
  cmd.run:
    - name: htpasswd -b {{ pillar['etc_dir'] }}/nginx/admin.d/htpasswd 'admin' '{{ pillar['admin_password'] }}'
    - require:
      - file: {{ pillar['etc_dir'] }}/nginx/admin.d/htpasswd

{%- endif %}
