munin-php5-fpm-plugins:
    file:
        - recurse
        - source: salt://munin/files/php5-fpm/plugins
        - name: /etc/munin/plugins
        - mode: 755
        - exclude_pat: '.*swp'

munin-php5-fpm-plugin-conf:
    file:
        - recurse
        - source: salt://munin/files/php5-fpm/plugin-conf.d
        - name: /etc/munin/plugin-conf.d
        - mode: 755
        - exclude_pat: '.*swp'
