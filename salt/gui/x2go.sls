include:
  - gui.desktop

x2go:
  pkgrepo.managed:
    - humanname: X2Go PPA repository
    - ppa: x2go/stable
  pkg.installed:
    - pkgs:
      - x2goserver 
      - x2goserver-xsession
    - require:
      - pkgrepo: x2go
      - sls: gui.desktop

  file.sed:
    - name: /etc/ssh/sshd_config
    - before: ^HostKey /etc/ssh/ssh_host_ecdsa_key
    - after: "#HostKey /etc/ssh/ssh_host_ecdsa_key # not compatible with x2go"
    - limit: ^HostKey
    - require:
      - pkg: x2go

ssh:
  service.running:
    - watch:
      - file.sed: x2go

