minion:
  file.managed:
    - source: salt://vagrant/minion
    - name: /etc/salt/minion
    - mode: 644
