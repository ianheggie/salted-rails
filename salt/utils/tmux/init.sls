tmux:
  pkg:
    - installed
  file.directory:
    - name: {{ pillar['homedir'] }}/.tmux
    - user: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    - mode: 755
    - require_in:
      - pkg: tmux

tmux-conf:
  file.managed:
    - name: {{ pillar['homedir'] }}/.tmux.conf
    - source: salt://utils/tmux/home/tmux.conf
    - user: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    #- template: jinja
    - mode: 644
    - require:
      - pkg: tmux

tmux-dev:
  file.managed:
    - name: {{ pillar['homedir'] }}/.tmux/dev
    - source: salt://utils/tmux/home/tmux-dev
    - user: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    #- template: jinja
    - mode: 644
    - require:
      - file.directory: tmux
