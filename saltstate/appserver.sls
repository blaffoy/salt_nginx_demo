tomcat7:
  pkg.installed

# This is a bit hacky, but the webapp requires that this path be writable
/home/russell/persistence/files:
  file.directory:
    - user: tomcat7
    - group: tomcat7
    - mode: 755
    - makedirs: True

/var/lib/tomcat7/webapps/companyNews.war:
  file.managed:
    - source: salt://files/companyNews.war
