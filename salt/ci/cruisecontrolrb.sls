include:
  - lang.ruby

{{ pillar['homedir'] }}/local:
  file.directory:
    - makedirs: True
    - user: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}

cruisecontrolrb-install:
  git.latest:
    - name: https://github.com/thoughtworks/cruisecontrol.rb
    - target: {{ pillar['homedir'] }}/local/cruisecontrol.rb
    - runas: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    - require:
      - file.directory: {{ pillar['homedir'] }}/local
  cmd.run:
    # Run twice if first fails (weirdness with installing ruby-debug)
    - name: {{ pillar['homedir'] }}/.rbenv/shims/bundle install || {{ pillar['homedir'] }}/.rbenv/shims/bundle install
    - cwd: {{ pillar['homedir'] }}/local/cruisecontrol.rb
    - user: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    - watch:
      - git: cruisecontrolrb-install

cruisecontrolrb-create-service:
  cmd.run:
    - name: cp -f {{ pillar['homedir'] }}/local/cruisecontrol.rb/daemon/cruise /etc/init.d/cruise && chmod +x /etc/init.d/cruise
    - watch:
      - cmd: cruisecontrolrb-install

cruisecontrolrb-fix-user:
  file.sed:
    - name: /etc/init.d/cruise
    - before: CRUISE_USER = .*
    - after: CRUISE_USER='{{ pillar['username'] }}'
    - limit: CRUISE_USER =
    - watch:
      - cmd: cruisecontrolrb-create-service
    
cruisecontrolrb-fix-home:
  file.sed:
    - name: /etc/init.d/cruise
    - before: CRUISE_HOME = .*
    - after: CRUISE_HOME='{{ pillar['homedir'] }}/local/cruisecontrol.rb'
    - limit: CRUISE_HOME =
    - watch:
      - cmd: cruisecontrolrb-create-service
    
cruisecontrolrb-fix-shebang:
  file.sed:
    - name: /etc/init.d/cruise
    - before: '#!/usr/bin/env.*'
    - after: '#!{{ pillar['homedir'] }}/.rbenv/shims/ruby'
    - watch:
      - cmd: cruisecontrolrb-create-service
    
cruisecontrolrb-register-service:
  cmd.run:
    - name: update-rc.d cruise defaults
    - watch:
      - file.sed: cruisecontrolrb-fix-home
      - file.sed: cruisecontrolrb-fix-user
      - file.sed: cruisecontrolrb-fix-shebang
  service.running:
    - name: cruise
    - watch:
      - cmd: cruisecontrolrb-register-service
    - require:
      - sls: lang.ruby

