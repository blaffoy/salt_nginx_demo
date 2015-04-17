nginx:
  pkg.installed

/etc/nginx/sites-available/companyNews:
  file.managed:
    - source: salt://companyNews.nginx.conf
    - template: jinja

/etc/nginx/sites-enabled/companyNews:
  file.symlink:
    - target: /etc/nginx/sites-available/companyNews

nginx-stop:
  service.dead:
    - name: nginx
    - reload: True

nginx-running:
  service.running:
    - name: nginx
    - reload: True
