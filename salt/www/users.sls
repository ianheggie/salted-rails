{{ pillar['www_dir'] }}:
  file.directory:
    - user: www-data
    - group: www-data
    - mode: 775
    - makedirs: True
    - require:
      - group: www-data
      - user: www-data

www-data:
  group.present:
    - system: True
  user.present:
    - system: True

