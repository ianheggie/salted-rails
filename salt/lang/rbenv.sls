include:
  - lang.ruby

{%- if ('ruby' in pillar['versions']) %}

rbenv:
  rbenv.installed:
    - name: {{ pillar['versions']['ruby'] }}
    - default: True
    - runas: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    - require:
      - pkg: ruby-deps
      
  file.append:
    - name: {{ pillar['homedir'] }}/.profile
    - user: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    - text:
      - export PATH="$HOME/.rbenv/bin:$PATH"
      - eval "$(rbenv init -)"
    - require:
      - rbenv.installed: rbenv
  gem.installed:
    - runas: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    - names:
      - bundler
    - require:
      - file: rbenv
  cmd.run:
    - name: {{ pillar['homedir'] }}/.rbenv/bin/rbenv rehash
    - user: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    - require:
      - gem: rbenv

rbenv-gem-rehash:
  git.latest:
    - name: git://github.com/sstephenson/rbenv-gem-rehash
    - runas: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    - rev: master
    - target: {{ pillar['homedir'] }}/.rbenv/plugins/rbenv-gem-rehash
    - force: True
    - require:
      - rbenv: rbenv

rbenv-update:
  git.latest:
    - name: git://github.com/rkh/rbenv-update
    - runas: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    - rev: master
    - target: {{ pillar['homedir'] }}/.rbenv/plugins/rbenv-update
    - force: True
    - require:
      - rbenv: rbenv

rbenv-which-ext:
  git.latest:
    - name: git://github.com/yyuu/rbenv-which-ext
    - runas: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    - rev: master
    - target: {{ pillar['homedir'] }}/.rbenv/plugins/rbenv-which-ext
    - force: True
    - require:
      - rbenv: rbenv

rbenv-binstubs:
  git.latest:
    - name: git://github.com/ianheggie/rbenv-binstubs
    - runas: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    - rev: master
    - target: {{ pillar['homedir'] }}/.rbenv/plugins/rbenv-binstubs
    - force: True
    - require:
      - rbenv: rbenv

rbenv-env:
  git.latest:
    - name: git://github.com/ianheggie/rbenv-env
    - runas: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    - rev: master
    - target: {{ pillar['homedir'] }}/.rbenv/plugins/rbenv-env
    - force: True
    - require:
      - rbenv: rbenv

rbenv-whatis:
  git.latest:
    - name: git://github.com/rkh/rbenv-whatis
    - runas: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    - rev: master
    - target: {{ pillar['homedir'] }}/.rbenv/plugins/rbenv-whatis
    - force: True
    - require:
      - rbenv: rbenv

rbenv-use:
  git.latest:
    - name: git://github.com/rkh/rbenv-use
    - runas: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    - rev: master
    - target: {{ pillar['homedir'] }}/.rbenv/plugins/rbenv-use
    - force: True
    - require:
      - rbenv: rbenv

{%- endif %}
