# 
# ruby deps
# 

rbenv-deps:
  pkg.installed:
    - pkgs:
      - autoconf 
      - automake
      - bison
      - build-essential
      - curl 
      - git
      - libc6-dev
      - libcurl4-openssl-dev
      - libfreeimage3
      - libfreeimage-dev
      - libmysqlclient-dev 
      - libncurses5-dev
      - libreadline-dev
      - libsqlite3-0
      - libsqlite3-dev
      - libssl-dev 
      - libtool
      - libxml2-dev 
      - libxslt1-dev 
      - libyaml-dev
      - openssl
      - python-software-properties 
      - sqlite3
      - subversion
      - zlib1g
      - zlib1g-dev 

ruby:
  rbenv.installed:
    - name: {{ pillar['ruby-version'] }}
    - default: True
    - runas: {{ pillar['username'] }}
    - require:
      - pkg: rbenv-deps

adjust_profile:
  file.append:
    - name: {{ pillar['homedir'] }}/.profile
    - user: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    - text:
      - export PATH="$HOME/.rbenv/bin:$PATH"
      - eval "$(rbenv init -)"
    - require:
      - rbenv.installed: ruby

base_gems:
  gem.installed:
    - runas: {{ pillar['username'] }}
    - names:
      - bundler
    - require:
      - file: adjust_profile
