# Handle firefox changing localhost to localhost.com then www.localhost.com if it can't connect to a port
# localhost.localdomain for those used to other systems

/etc/hosts:
  file.append:
    - user: root
    - group: root
    - text:
      - 127.0.0.1       localhost localhost.com www.localhost.com localhost.localdomain
