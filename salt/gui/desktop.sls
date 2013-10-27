include:
  - gui.lxde

desktop:
  cmd.run:
    - name: 'true'
    - require:
      - sls: gui.lxde

