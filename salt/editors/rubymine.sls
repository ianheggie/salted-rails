include:
  - lang.java

{{ pillar['homedir'] }}/local/tmp:
  file.directory:
    - makedirs: True
    - clean: True
    - user: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}

rubymine-download:
  cmd.run:
    - name: wget -c http://download.jetbrains.com/ruby/RubyMine-{{ pillar['rubymine-version'] }}.tar.gz
    - cwd: {{ pillar['homedir'] }}/local
    - user: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    - unless: [ -d {{ pillar['homedir'] }}/local/RubyMine-{{ pillar['rubymine-version'] }} ]
    - require:
      - file.directory: {{ pillar['homedir'] }}/local/tmp

rubymine-extract:
  cmd.run:
    - name: tar xfz ../RubyMine-{{ pillar['rubymine-version'] }}.tar.gz
    - cwd: {{ pillar['homedir'] }}/local/tmp
    - user: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    - unless: [ -d ../RubyMine-{{ pillar['rubymine-version'] }} ] 
    - require:
      - cmd: rubymine-download

# The tar file contains extra version numbers in its top directory
rubymine-rename:
  cmd.run:
    - name: mv RubyMine-* ../RubyMine-{{ pillar['rubymine-version'] }}
    - cwd: {{ pillar['homedir'] }}/local/tmp
    - user: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    - unless: [ -d ../RubyMine-{{ pillar['rubymine-version'] }} ] 
    - require:
      - cmd: rubymine-extract

rubymine-adjust_profile:
  file.append:
    - name: {{ pillar['homedir'] }}/.profile
    - user: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    - text:
      - export PATH="{{ pillar['homedir'] }}/RubyMine-{{ pillar['rubymine-version'] }}/bin:$PATH"
    - require:
      - cmd: rubymine-rename

