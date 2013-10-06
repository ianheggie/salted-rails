include:
  - lang.java
  - www.users

teamcity-download:
  file.directory:
    - name: /tmp/TeamCity
    - makedirs: True
    - user: www-data
    - group: www-data
    - require:
      - sls: www.users
  cmd.run:
    - name: wget -c http://download.jetbrains.com/teamcity/TeamCity-{{ pillar['teamcity-version'] }}.tar.gz
    - unless: test -d /var/TeamCity/bin
    - cwd: /tmp
    - user: www-data
    - group: www-data
    - require:
      - file.directory: teamcity-download

teamcity-extract:
  cmd.run:
    - name: tar xfz /tmp/TeamCity-{{ pillar['teamcity-version'] }}.tar.gz 
    - cwd: /tmp/TeamCity
    - user: www-data
    - group: www-data
    - require:
      - cmd: teamcity-download

teamcity-install:
  cmd.run:
    - name: rm -rf /var/TeamCity && mv /tmp/TeamCity/* /var/TeamCity && rm -fr /tmp/TeamCity
    - cwd: /tmp
    - unless: test -d /var/TeamCity/bin
    - require:
      - cmd: teamcity-extract

teamcity-setup-service:
  file.managed:
    - name: {{ pillar['etc_dir'] }}/init.d/teamcity
    - source: salt://ci/teamcity/etc/init.d/teamcity
    - user: root
    - group: root
    - mode: 755
    - require:
      - cmd: teamcity-install

teamcity:
  service:
    - running
    - enable: True
    - reload: True
    - watch:
      - file: {{ pillar['etc_dir'] }}/init.d/teamcity
  require:
    - file: teamcity-setup-service

