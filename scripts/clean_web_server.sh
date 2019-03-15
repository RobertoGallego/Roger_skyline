#!/bin/sh

echo "\e[92m--- INSTALLING FIREWALL UFW ---\e[0m"

sudo apt-get install ufw
sudo ufw enable
sudo ufw status verbose
sudo ufw allow ssh

echo "\e[92m--- INSTALLING APACHE ---\e[0m"

sudo apt-get clean
sudo apt-get update
sudo apt-get remove --purge apache2 apache2-utils
sudo rm -rf /var/www/html
sudo mkdir /var/www/html
sudo chmod 0755 /var/www/html
sudo apt-get install apache2

# --- ADJUSTING FIREWALL ---
#sudo ufw app list - LISTAS DE PUERTOS ABIERTOS
#APACHE PROFILE WWW - WWW Cache - WWW Full - WWW Secure

#sudo ufw allow 'WWW'

#sudo ufw status - VERIFICAR CAMBIOS

# --- CHECKING YOUR WEB SERVER ---

#sudo systemctl status apache2 - VERIFICAR APACHE

echo "\e[31m------------------- Important line --------------------\e[0m"
echo "\e[31m-------------------------------------------------------\e[0m"
echo "\e[92mChecking your Common Name (e.g. server FQDN or your name)\e[0m"
hostname -I
echo "\e[92--- CREATING SSL CERTIFICATE ---\e[0m"

sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt

#Common Name IP

# --- CONFIG APACHE TO USE SSL ---

#we have created our key and certificate files under the /etc/ssl

echo "\e[92m--- Creating an Apache Configuration Snippet with Strong Encryption Settings ---\e[0m"

#creamos un archivo ssl-params.conf
#tengo que pegar esto en el archivo ssl-params.conf

cat << EOF > /etc/apache2/conf-available/ssl-params.conf
SSLCipherSuite EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH
SSLProtocol All -SSLv2 -SSLv3 -TLSv1 -TLSv1.1
SSLHonorCipherOrder On
# Disable preloading HSTS for now.  You can use the commented out header line that includes
# the "preload" directive if you understand the implications.
# Header always set Strict-Transport-Security "max-age=63072000; includeSubDomains; preload"
Header always set X-Frame-Options DENY
Header always set X-Content-Type-Options nosniff
# Requires Apache >= 2.4
SSLCompression off
SSLUseStapling on
SSLStaplingCache "shmcb:logs/stapling-cache(150000)"
# Requires Apache >= 2.4.11
SSLSessionTickets Off
EOF

echo "\e[92m--- Modifying the Default Apache SSL Virtual Host File ---\e[0m"

#hacemos un backup del antiguo default-ssl.conf

sudo cp /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-available/default-ssl.conf.bak

echo "\e[92m--- Backup done ---\e[0m"

#ahora abrimos el fichero y remplazamos

cat << EOF > /etc/apache2/sites-available/default-ssl.conf
<IfModule mod_ssl.c>
<VirtualHost _default_:443>
ServerAdmin rvgallego@hotmail.com
ServerName 10.12.9.120

DocumentRoot /var/www/html

ErrorLog ${APACHE_LOG_DIR}/error.log
CustomLog ${APACHE_LOG_DIR}/access.log combined

SSLEngine on

SSLCertificateFile      /etc/ssl/certs/apache-selfsigned.crt
SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key

<FilesMatch "\.(cgi|shtml|phtml|php)$">
SSLOptions +StdEnvVars
</FilesMatch>
<Directory /usr/lib/cgi-bin>
SSLOptions +StdEnvVars
</Directory>
</VirtualHost>
</IfModule>
EOF

# --- Modifying the HTTP Host File to Redirect to HTTPS ---

#vamos aca y agregamos esta linea o la remplazamos.

#sudo nano /etc/apache2/sites-available/000-default.conf

#Redirect permanent "/" "https://your_domain_or_IP/"

echo "\e[92m--- Adjusting the firewall ---\e[0m"

sudo ufw allow 'WWW Full'

# --- Enabling the Changes in Apache ---

sudo a2enmod ssl
sudo a2enmod headers
sudo a2ensite default-ssl
sudo a2enconf ssl-params
echo "ServerName localhost" | sudo tee /etc/apache2/conf-available/fqdn.conf
sudo a2enconf fqdn
sudo systemctl restart apache2
sudo apache2ctl configtest

#syntax OK podemos reiniciar apache2

sudo systemctl restart apache2
sudo /etc/init.d/apache2 restart
sudo /etc/init.d/ufw restart

#-----------------------------------------------

sudo sed -i "13iRedirect permanent / https://10.11.8.120/" /etc/apache2/sites-available/000-default.conf
sudo apache2ctl configtest
sudo systemctl restart apache2

#-----------------------------------------------
echo "\e[92mSuccessfully implemented.\e[0m"

# --- Testing Encryption ---

#open ip de la web con ifconfig
