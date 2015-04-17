boto:
  pip.installed

/etc/salt/master:
  file.managed:
    - contents: |
        file_roots:
          base:
            - /srv/salt
        pillar_roots:
          base:
            - /srv/pillar
