include:
  - lang.ruby

railsapp_gems:
  file.recurse:
    - source: salt://railsapp/files
    - name: /tmp
    - file_mode: 644
    - user: {{ pillar['username'] }}
  cmd.run:
    # Run twice if first fails (weirdness with installing ruby-debug)
    - name: {{ pillar['homedir'] }}/.rbenv/shims/bundle install || {{ pillar['homedir'] }}/.rbenv/shims/bundle install
    - cwd: /tmp
    - user: {{ pillar['username'] }}
    - require:
      - file: railsapp_gems
      - gem.installed: base_gems

