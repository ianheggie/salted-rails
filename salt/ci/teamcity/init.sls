include:
  - lang.java

teamcity-download:
  file.directory:
    - name: {{ pillar['homedir'] }}/tmp/teamcity
    - makedirs: True
    - user: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
  cmd.run:
    - name: wget -nv -c http://download.jetbrains.com/teamcity/TeamCity-{{ pillar['versions']['teamcity'] }}.tar.gz
    - unless: test -d {{ pillar['homedir'] }}/local/TeamCity-{{ pillar['versions']['teamcity'] }}/bin
    - cwd: {{ pillar['homedir'] }}/tmp/teampcity
    - user: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    - unless: test -d {{ pillar['homedir'] }}/local/TeamCity-{{ pillar['versions']['teamcity'] }}/bin
    - require:
      - file.directory: teamcity-download

teamcity-extract:
  cmd.run:
    - name: tar xfz /tmp/TeamCity-{{ pillar['versions']['teamcity'] }}.tar.gz 
    - cwd: {{ pillar['homedir'] }}/tmp/teampcity
    - user: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    - unless: test -d {{ pillar['homedir'] }}/local/TeamCity-{{ pillar['versions']['teamcity'] }}/bin
    - require:
      - cmd: teamcity-download

teamcity-install:
  cmd.run:
    - name: mv TeamCity-* ../../TeamCity-{{ pillar['versions']['teamcity'] }}
    - cwd: {{ pillar['homedir'] }}/tmp/teampcity
    - unless: test -d {{ pillar['homedir'] }}/local/TeamCity-{{ pillar['versions']['teamcity'] }}/bin
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
    - sls:lang.java

