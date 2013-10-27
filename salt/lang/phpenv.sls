include:
  - scm

phpenv_deps:
  pkg.installed:
    - names:
      - build-essential
      - openssl
      - curl
      - zlib1g
      - zlib1g-dev
      - libssl-dev
      - libyaml-dev
      - libsqlite3-0
      - libsqlite3-dev
      - sqlite3
      - libxml2-dev
      - libxslt1-dev
      - autoconf
      - libc6-dev
      - libncurses5-dev
      - automake
      - libtool
      - bison

# 
# phpenv and php-build installation
# 

#{{ pillar['homedir'] }}/.phpenv:
#  file.directory:
#    - user: {{ pillar['username'] }}
#    - group: {{ pillar['username'] }}
#    - makedirs: True

phpenv:
  git.latest:
    - name: git://github.com/phpenv/phpenv.git
    - runas: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    - rev: master
    - target: {{ pillar['homedir'] }}/.phpenv
    - force: True
    - require:
      - pkg: phpenv_deps
  file.append:
    - name: {{ pillar['homedir'] }}/.profile
    - user: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    - text:
      - export PATH="$HOME/.phpenv/bin:$PATH"
      - eval "$(phpenv init -)"
    - require:
      - git: phpenv

phpenv-rehash:
  cmd.run:
    - name: {{ pillar['homedir'] }}/.phpenv/bin/phpenv rehash
    - user: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    - require:
      - file: phpenv
{%- if 'php' in pillar['versions'] %}
      - cmd: phpenv-install-php

phpenv-install-php:
  cmd.run:
    - name: {{ pillar['homedir'] }}/.phpenv/bin/phpenv install {{ pillar['versions']['php'] }}
    - user: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    - require:
      - git: phpenv

phpenv-global:
  cmd.run:
    - name: {{ pillar['homedir'] }}/.phpenv/bin/phpenv global {{ pillar['versions']['php'] }}
    - user: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    - require:
      - cmd: phpenv-rehash

{%- endif %}
