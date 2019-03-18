su - root
apt-get install sudo
usermod -aG rv				#put ur sudo new user and password
su - rv
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install vim

echo "--- static ips for ssh ---";

/etc/network/interfaces

remplazar linea 10 por: iface enpOs3 inet dhcp // static
address new ifconfig ip    10.11.7.120
netmask                    255.255.255.252
gateway					   10.11.254.254

sudo vim /etc/ssh/sshd_config

borrar puerto original y remplazarlo por otro ex: 7900

sudo apt-get install ufw
sudo apt-get install fail2ban 
sudo apt-get install portsentry
sudo apt-get install nmap
sudo apt-get install postfix 
sudo apt-get install mailutils

sudo vim /etc/aliases

sudo ufw allow 7900
