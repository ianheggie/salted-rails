include:
  - lang.ruby

tmp_railsapp_gems:
  file.directory:
    - name: /tmp/railsapp_gems
    - file_mode: 755
    - user: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    - makedirs: True
    - clean: True

railsapp_gems:
  file.recurse:
    - source: salt://files/
    - name: /tmp/railsapp_gems
    - file_mode: 644
    - user: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    - require:
      - file.directory: tmp_railsapp_gems
  cmd.run:
    # Run twice if first fails (weirdness with installing ruby-debug)
    - name: {{ pillar['homedir'] }}/.rbenv/shims/bundle install || {{ pillar['homedir'] }}/.rbenv/shims/bundle install
    - cwd: /tmp/railsapp_gems
    - user: {{ pillar['username'] }}
    - group: {{ pillar['username'] }}
    - require:
      - file: railsapp_gems
      - gem.installed: base_gems

