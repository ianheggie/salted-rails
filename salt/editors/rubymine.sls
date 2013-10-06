include:
  - lang.java

{{ pillar['homedir'] }}/local:
  file.directory:
    - makedirs: True
    - user: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}

rubymine-download:
  cmd.run:
    - name: wget -c http://download.jetbrains.com/ruby/RubyMine-{{ pillar['rubymine-version'] }}.tar.gz
    - cwd: {{ pillar['homedir'] }}/local
    - user: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    # - unless: mine -v 2>/dev/null
    - unless: [ -d {{ pillar['homedir'] }}/local/RubyMine-{{ pillar['rubymine-version'] }} ] 2>/dev/null
    - require:
      - file.directory: {{ pillar['homedir'] }}/local

rubymine-extract:
  cmd.run:
    - name: tar xfz RubyMine-5.4.3.tar.gz
    - cwd: {{ pillar['homedir'] }}/local
    - user: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    # - unless: mine -v 2>/dev/null
    - unless: [ -d RubyMine-5.4.3 ] 2>/dev/null
    - require:
      - cmd: 

#rubymine-install:
#  cmd.run:
#  
#
#
#php-composer:
#  cmd.run:
#    - name: curl -s https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer
#    - unless: composer -v 2>/dev/null
#    - require:
#      - pkg: php
#
## http://download.jetbrains.com/ruby/RubyMine-5.4.3.tar.gz
#
#
