include:
  - lang.java


rubymine-download:
  file.directory:
    - name: {{ pillar['homedir'] }}/local/tmp/rubymine
    - makedirs: True
    - clean: True
    - user: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
  cmd.run:
    - name: wget -nv -c http://download.jetbrains.com/ruby/RubyMine-{{ pillar['versions']['rubymine'] }}.tar.gz
    - cwd: {{ pillar['homedir'] }}/local
    - user: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    - unless: test -d {{ pillar['homedir'] }}/local/RubyMine-{{ pillar['versions']['rubymine'] }}/bin
    - require:
      - file.directory: rubymine-download

rubymine-extract:
  cmd.run:
    - name: tar xfz ../RubyMine-{{ pillar['versions']['rubymine'] }}.tar.gz
    - cwd: {{ pillar['homedir'] }}/local/tmp/rubymine
    - user: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    - unless: test -d {{ pillar['homedir'] }}/local/RubyMine-{{ pillar['versions']['rubymine'] }}/bin
    - require:
      - cmd: rubymine-download

# The tar file contains extra version numbers in its top directory
rubymine-install:
  cmd.run:
    - name: mv RubyMine-* ../../RubyMine-{{ pillar['versions']['rubymine'] }}
    - cwd: {{ pillar['homedir'] }}/local/tmp/rubymine
    - user: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    - unless: test -d {{ pillar['homedir'] }}/local/RubyMine-{{ pillar['versions']['rubymine'] }}/bin
    - require:
      - cmd: rubymine-extract

rubymine-adjust_profile:
  file.append:
    - name: {{ pillar['homedir'] }}/.profile
    - user: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    - text:
      - export PATH="{{ pillar['homedir'] }}/RubyMine-{{ pillar['versions']['rubymine'] }}/bin:$PATH"
    #- require:
    #  - cmd: rubymine-rename

