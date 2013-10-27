vim:
  pkg.installed:
    - name: vim
  cmd.wait:
    - names:
      - update-alternatives --set editor vim
    - require:
      - pkg: vim
    - watch:
      - pkg: vim
  file.managed:
    - source: salt://editors/vim/vimrc
    - name: {{ pillar['homedir'] }}/.vimrc
    - user: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    - template: jinja
    - replace: false
    - mode: 644
    - require:
      - pkg: vim

vim-pathogen:
  file.directory:
    - name: {{ pillar['homedir'] }}/.vim/autoload
    - user: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    - mode: 775
    - makedirs: True
    - require:
      - pkg: vim
  cmd.run:
    - name: curl -Sso {{ pillar['homedir'] }}/.vim/autoload/pathogen.vim https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim
    - user: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    - require:
      - file.directory: vim-pathogen

vim-bundle:
  file.directory:
    - name: {{ pillar['homedir'] }}/.vim/bundle
    - user: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    - mode: 775
    - makedirs: True
    - require:
      - pkg: vim

vim-rails:
  git.latest:
    - name: git://github.com/tpope/vim-rails.git
    - runas: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    - rev: master
    - target: {{ pillar['homedir'] }}/.vim/bundle/vim-rails
    - force: True
    - require:
      - file.directory: vim-bundle

vim-bundler:
  git.latest:
    - name: git://github.com/tpope/vim-bundler.git
    - runas: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    - rev: master
    - target: {{ pillar['homedir'] }}/.vim/bundle/vim-bundler
    - force: True
    - require:
      - file.directory: vim-bundle

vim-NERDtree:
  git.latest:
    - name: git://github.com/scrooloose/nerdtree.git
    - runas: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    - rev: master
    - target: {{ pillar['homedir'] }}/.vim/bundle/nerdtree
    - force: True
    - require:
      - file.directory: vim-bundle


