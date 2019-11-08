# Install NGINX
nginx:
  pkg.installed: []
  service.running:
    - enable: True
    - full_restart: True
    - watch:
      - file: /etc/nginx/*
    - require:
      - pkg: nginx

# Replace default NGINX Virtual Hosts File
/etc/nginx/sites-available/default:
  file.managed:
    - source: salt://files/etc/nginx/sites-available/default
    - user: root
    - group: root
    - mode: 640

# Copy test example.com index.html file
/var/www/html/index.html:
  file.managed:
    - source: salt://files/var/www/html/index.html
    - user: root
    - group: root
    - mode: 644

# Copy Custom 404 Error html file
/var/www/html/custom_404.html:
  file.managed:
    - source: salt://files/var/www/html/custom_404.html
    - user: root
    - group: root
    - mode: 644

# Copy www-example-com NGINX Virtual Hosts File
/etc/nginx/sites-available/www-example-com:
  file.managed:
    - source: salt://files/etc/nginx/sites-available/www-example-com
    - user: root
    - group: root
    - mode: 640

#Enable example.com Virtual Hosts file via Symlink
/etc/nginx/sites-enabled/www-example-com:
  file.symlink:
    - target: /etc/nginx/sites-available/www-example-com
    - require:
      - file: /etc/nginx/sites-available/www-example-com

# Copy backend-3400 NGINX Virtual Hosts File
/etc/nginx/sites-available/backend-3400:
  file.managed:
    - source: salt://files/etc/nginx/sites-available/backend-3400
    - user: root
    - group: root
    - mode: 640

#Enable backend-3400 Virtual Hosts file via Symlink
/etc/nginx/sites-enabled/backend-3400:
  file.symlink:
    - target: /etc/nginx/sites-available/backend-3400
    - require:
      - file: /etc/nginx/sites-available/backend-3400

#Configure Firewall to allow SSH and NGINX (TCP/3200)
config-ufw:
  cmd.run:
    - name: |
        ufw allow ssh/tcp
        ufw allow 3200/tcp
        ufw logging on
        ufw --force enable