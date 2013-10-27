include:
  - scm
  - databases.packages

ruby-deps:
  pkg.installed:
    - pkgs:
      - autoconf
      - automake
      - bash
      - bison
      - build-essential
      - curl
      - libc6-dev
      - libcurl4-openssl-dev
      - libfreeimage3
      - libfreeimage-dev
      - libncurses5-dev
      - libreadline6
      - libreadline6-dev
      - libreadline-dev
      - libssl-dev
      - libtool
      - libxml2-dev
      - libxslt1-dev
      - libyaml-dev
      - openssl
      - python-software-properties
      - zlib1g
      - zlib1g-dev
    - require:
      - pkg: databases-packages

ruby:
  pkg.installed:
    - pkgs:
      - ruby
      - rubygems
    - require:
      - pkg: ruby-deps
  gem.installed:
    - names:
      - bundler
      - rake
    - require:
      - pkg: ruby

