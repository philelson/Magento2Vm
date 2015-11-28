#!/usr/bin/env bash

#Check for any updates
yum -y update
yum -y upgrade
yum install -y httpd
yum install -y wget
yum install -y nano
yum install -y git
yum install -y mod_ssl
yum install -y nmap
yum install -y sendmail
yum install -y bzip2
yum install -y iptables-services
yum install -y htop

#Install required repositories
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install -y https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
yum install -y http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
yum install -y http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm
yum install -y https://mirror.webtatic.com/yum/el7/webtatic-release.rpm

yum install -y --enablerepo=webtatic-testing php56w php56w-opcache
yum install -y php56w-common
yum install -y php56w-mcrypt
yum install -y php56w-mysql
yum install -y php56w-mbstring
yum install -y php56w-gd
yum install -y php56w-dom
yum install -y php56w-intl

yum install -y mysql-community-server   #MySql Server
yum install -y redis                    #Redis key value engine
#yum install -y php-pecl-redis           #PHP Redis package

#Create the apache config directories
mkdir -p /etc/httpd/sites-available
mkdir -p /etc/httpd/sites-enabled
mkdir -p /var/www/ops/service/redic/log/

#Create the new apache config for sites enabled
echo "" >> /etc/httpd/conf/httpd.conf
echo "#" >> /etc/httpd/conf/httpd.conf
echo "#Include the sites enabled config files" >> /etc/httpd/conf/httpd.conf
echo "#" >> /etc/httpd/conf/httpd.conf
echo "Include /etc/httpd/sites-available/*.conf" >> /etc/httpd/conf/httpd.conf

# Replace contents of default Apache vhost
# --------------------
# Apache vhosts
VHOST=$(cat <<EOF
    #Admin Vhost
    <VirtualHost *:80>
        DocumentRoot "/var/www/public"
        ServerName magento2.dev

        SetEnv  MAGE_RUN_CODE           default
        SetEnv  MAGE_RUN_TYPE           store
        SetEnv  MAGE_IS_DEVELOPER_MODE  1

        <Directory "/var/www/public">
            AllowOverride All
        </Directory>
    </VirtualHost>
EOF
)

#Create the config file and the sym link
echo "$VHOST" > /etc/httpd/sites-available/magento.2.conf
ln -s /etc/httpd/sites-available/magento.2.conf /etc/httpd/sites-enabled/magento.2.conf

#Do the database thing....
systemctl start mysqld.service
mysql -u root -e "GRANT ALL PRIVILEGES ON root.* TO 'root'@'localhost' IDENTIFIED BY 'password'; FLUSH PRIVILEGES;"
mysql -u root -ppassword -e "DROP DATABASE IF EXISTS magento2; CREATE DATABASE IF NOT EXISTS magento2"

#
# Now we want to create the redis service
#
chmod 777 /var/www/ops/services/redis/redis.service
ln -s /var/www/ops/services/redis/redis.service /etc/systemd/system/redis.service
chmod 777 /etc/systemd/system/redis.service

#
# Install composer
#
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

#
# Keys
#
PUBLIC_KEY=$(cat <<EOF
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDwbX5BQ7mTI9YEpy5bTfefXhlmxq9FtGmp9x13VddYGJ7xWgHkRjKLFS21IJRfUue8alQAgJePjKzwiPIgU0PTe53/2B7qNFw7qmZ2IKNwmkj2pxCY9ivM9PsO5JbddcvX3GQvwGrrQYDyy2xZe+UtzoLQQ2We4aKFMzE/E97H1zrM7UH2ePAemOXND7VoQSXQBtOEwMLMdV7Xr1CyH2G/Pqk3j4nj9agoIWOWzSbqVaY0fpcHFyYvSmV4QyWG1JCyuR8FHJQ1fDZU7+65SvZgmhFxhbUQlmMmhjsHLiHZKo3Tr3/vGvE9L/Y6CmoriU2LpPfTmL9wuLOoM1mLStBx vagrant@magento2.dev
EOF
)

PRIVATE_KEY=$(cat <<EOF
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEA8G1+QUO5kyPWBKcuW033n14ZZsavRbRpqfcdd1XXWBie8VoB
5EYyixUttSCUX1LnvGpUAICXj4ys8IjyIFND03ud/9ge6jRcO6pmdiCjcJpI9qcQ
mPYrzPT7DuSW3XXL19xkL8Bq60GA8stsWXvlLc6C0ENlnuGihTMxPxPex9c6zO1B
9njwHpjlzQ+1aEEl0AbThMDCzHVe169Qsh9hvz6pN4+J4/WoKCFjls0m6lWmNH6X
BxcmL0pleEMlhtSQsrkfBRyUNXw2VO/uuUr2YJoRcYW1EJZjJoY7By4h2SqN069/
7xrxPS/2OgpqK4lNi6T305i/cLizqDNZi0rQcQIDAQABAoIBAQDrovR1tJGhkyLD
hrKZS+3gJNKSdzH7CBnzOb2IYvpeXisQ8p0eBGqvA3+7oIWqc0+pyzAvGdjxGPe5
+w4K/nBgSiyNPlz2P4ER/SzUo6Jrztqp2w0aTVKaWpPggcsWm8e/9UG/xz9C+P0P
eK3ledcgsOBmi1eCgzPMhmLCpo/WnMWdDD7KP5SfyPVoCGzjp8HztcmJ3E7ANxal
tuGaad/B3HyWDESgvVUgX2SqjvjOmfdr76mcwGxsUG3ETYm3t5beZar8vdqixGiD
HHrtZyoFZGxK06sn8n8+5L5Nisgvyr5r/6lwyFH7MrexeZWmkAnVjfNxZ7gvSdaF
P9ZCZfIRAoGBAP1KnvceFyjbgSRsOMKfp/EXJQWJeqJMwlWZwn+sZ/5WyUfQWdVG
S7P6iv9CdqgqWkgmjhA/yXos3x3Kvcu18NmpfbZQPWh4Sn128FLm0NdYR1QCiz98
16KFkGBkTfzjw4mE91+AkcLHW0eULq4ZdgGe+ITa12o+ag76jWfywkr1AoGBAPL/
qG+G4O6TISwxWgoeeVKVpGzXcJx1Ewi+lij1sj8GQIN1Ro3T7Z04mwn60H9PQvwc
wwAnn6SyZ4qJngWPHyVo5IRghFE4pPwogW2OwMvi6pvs6nwps4YytdkpER7k6gj6
yzhS4nbUOSn6XDfpOVyR7xrCusQhz4bfoFucu7oNAoGARrMufgHLKx9iA72ldkXE
RdpU/h+quGS+ldAuZx7DhE3LLx1sBcjyVpFnfOqbXkM8IgmI++YiIdUmjhVKNvNZ
ABh8O4hYK7Hv8OdjG3DL+F/uwPdY0ObS9c1cSFuXHTCiIt+XgPPNO9YTl344LWZz
9u3dpo/DMyeqyPWMxOgQ7YUCgYBJdYgRzxCIjunkVjcGABhlIt/GF4rvgWTzq8nx
L/VmoBk4pGdj0MFwWgBkj/IfynJRjNBWZ6QXQeeTNe8TdyTPRlpuuk7Fzv3xTL1z
xUf7WunZoVFxn5mp5AKdV5DZahJmDIsKx+O2UInHauwd6t9wYJ2L1XpoeGAoQcpU
Z5lIsQKBgCwhXqEyOblqUfHnqTuAo0YgaLcfqb5IF1RusAvx2YrL+IgfVJ6/RY5n
Dae5S8caivfe2IaahJACzHmGHKrULjBJq5MqAse5W7VVJzYPoHMTPXmTdAAskAq1
0eCGGfR8eZpTbxGypEH2oPh+ow9cHCiq4Qk+ZmTdPuVsAnXm2SLV
-----END RSA PRIVATE KEY-----
EOF
)

echo "$PUBLIC_KEY" > /home/vagrant/.ssh/id_rsa.pub
echo "$PRIVATE_KEY" > /home/vagrant/.ssh/id_rsa

#
# Disable SE Linux on Centos 7
#
SELINUX=$(cat <<EOF
SELINUX=disabled
SELINUXTYPE=targeted
SETLOCALDEFS=0
EOF
)

echo "$SELINUX" > /etc/sysconfig/selinux
setenforce  0

#
# Disable new Firewall
#
systemctl disable firewalld.service
systemctl stop firewalld.service
systemctl enable iptables.service
systemctl enable ip6tables.service
systemctl start iptables.service
systemctl start ip6tables.service

IPTABLES=$(cat <<EOF
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 443 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 8080 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 3306 -j ACCEPT
-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A FORWARD -j REJECT --reject-with icmp-host-prohibited
COMMIT
EOF
)

echo "$IPTABLES" > /etc/sysconfig/iptables
iptables -F

#
# Auto Start the required services
#
systemctl enable httpd.service
systemctl enable mysqld.service
systemctl enable redis

#
# Start the services
#
systemctl start httpd.service
systemctl start mysqld.service
systemctl start redis

#
# Magento setup
#
cd /var/www/
git clone git@github.com:magento/magento2.git public
cd public
chmod -R 777 var/ app/etc/ pub
chown -R vagrant:apache ./
find . -type d -exec chmod 770 {} \; && find . -type f -exec chmod 660 {} \; && chmod u+x bin/magento
composer install

bin/magento setup:install --base-url=http://magento.dev:8080/ \
--db-host=localhost --db-name=magento2 \
--db-user=root --db-password=password \
--admin-firstname=admin --admin-lastname=user --admin-email=team@pegasus-commerce.com \
--admin-user=admin --admin-password=123123pass --language=en_GB \
--currency=GBP --timezone=Europe/London --cleanup-database \
--sales-order-increment-prefix="ORD$" --session-save=db --use-rewrites=1

