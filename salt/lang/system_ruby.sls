ruby-deps:
  pkg:
    - installed
    - names:
      - build-essential
      - openssl
      - libreadline6
      - libreadline6-dev
      - curl
      - git
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
      - subversion

ruby:
  pkg.installed:
    - names:
      - ruby
      - rubygems
    - require:
      - ruby-deps

gems:
  gem.installed:
    - names:
      - bundler
      - rake
    - require:
      - ruby
