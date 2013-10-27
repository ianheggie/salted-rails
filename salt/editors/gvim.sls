include:
  - gui.desktop
  - editors.vim

gvim:
  pkg.installed:
    - name: vim-gtk
    - require:
      - sls: gui.desktop
