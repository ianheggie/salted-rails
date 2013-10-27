include:
  - scm

jenv_deps:
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
# jenv and java-build installation
# 

#{{ pillar['homedir'] }}/.jenv:
#  file.directory:
#    - user: {{ pillar['username'] }}
#    - group: {{ pillar['username'] }}
#    - makedirs: True

jenv:
  git.latest:
    - name: git://github.com/gcuisinier/jenv
    - runas: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    - rev: master
    - target: {{ pillar['homedir'] }}/.jenv
    - force: True
    - require:
      - pkg: jenv_deps
  file.append:
    - name: {{ pillar['homedir'] }}/.profile
    - user: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    - text:
      - export PATH="$HOME/.jenv/bin:$PATH"
      - eval "$(jenv init -)"
    - require:
      - git: jenv

jenv-rehash:
  cmd.run:
    - name: {{ pillar['homedir'] }}/.jenv/bin/jenv rehash
    - user: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    - require:
      - file: jenv

# Install java manually at this point!
