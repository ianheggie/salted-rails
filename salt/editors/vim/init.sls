vim:
  pkg.installed:
    - name: vim

vim_alternatives:
  cmd.wait:
    - names:
      - update-alternatives --set editor vim
    - require:
      - pkg: vim
    - watch:
      - pkg: vim
