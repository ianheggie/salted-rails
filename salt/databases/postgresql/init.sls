include:
  - databases.postgresql.client

postgresql:
  pkg.installed:
    - pkgs:
      - postgresql 
    - require:
      - sls: databases.postgresql.client

