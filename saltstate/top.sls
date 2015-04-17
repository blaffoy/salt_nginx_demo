base:
  '*':
    - salt-minion

  'G@roles:appserver':
    - appserver

  'G@roles:loadbalancer':
    - loadbalancer

  'G@roles:salt-master':
    - salt-master
    - cloud-master
