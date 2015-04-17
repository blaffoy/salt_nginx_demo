/etc/salt/minion:
  file.append:
    - text: |
        mine_functions:
          grains.get: ['public_ip']

salt-minion-restart:
  cmd.run:
    - name: service salt-minion restart
