#!/usr/bin/env bash

#
# Check for any updates

yum -y update
yum -y upgrade

#
# Install defaults
#
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

#
# Install required repositories
#
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install -y https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
yum install -y http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
yum install -y http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm

#
# Install PHP 5.6
#
yum install -y --enablerepo=webtatic-testing php56w php56w-opcache
yum install -y php56w-common
yum install -y php56w-mcrypt
yum install -y php56w-mysql
yum install -y php56w-mbstring
yum install -y php56w-gd
yum install -y php56w-dom
yum install -y php56w-intl

#
# Mysql and Redis Cache
#
yum install -y mysql-community-server   #MySql Server
yum install -y redis                    #Redis key value engine

#
# Create the apache config directories
#
mkdir -p /etc/httpd/sites-available
mkdir -p /etc/httpd/sites-enabled
mkdir -p /var/www/ops/service/redic/log/
mkdir -p ~/.ssh/

#
# Create the new apache config for sites enabled
#
echo "" >> /etc/httpd/conf/httpd.conf
echo "#" >> /etc/httpd/conf/httpd.conf
echo "#Include the sites enabled config files" >> /etc/httpd/conf/httpd.conf
echo "#" >> /etc/httpd/conf/httpd.conf
echo "Include /etc/httpd/sites-available/*.conf" >> /etc/httpd/conf/httpd.conf

#
# Create the VHOST for the website
#
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

echo "$VHOST" > /etc/httpd/sites-available/magento.2.conf
ln -s /etc/httpd/sites-available/magento.2.conf /etc/httpd/sites-enabled/magento.2.conf

#
# Crate the database
#
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
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDFUWdiFeoyyjF3ladV4bVl/jUr2mNTMwYU6mKlP1OYrU9dxWWzSgppP1XyiKVnsjGQVIO60h8GTjrf1UwOg7cECJpz6F2B9k9eZ0xRxAkPC6BHXxwY+DqBB131Zmi401JCquYAOKmDkinpxvuAvXCwUHvbxaNn1R7SpHhbGwfXD5i3o4NLOuhkzggo+cvw05pDgzKVGklp8b6yeSpf5UtgRd3pj0tapkXmcl3EIxiX3KVjXRwc75dFc0gG4KX7hGQfXRX7JQXTY+d1/f45v1/KZNfRwBzxAsHxrvA8D1oBZXddz5nFVPAvXcRtDaDXEukuLHCLvKccOKrY+LQtB2IJ root@magento2.dev
EOF
)

PRIVATE_KEY=$(cat <<EOF
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAxVFnYhXqMsoxd5WnVeG1Zf41K9pjUzMGFOpipT9TmK1PXcVl
s0oKaT9V8oilZ7IxkFSDutIfBk4639VMDoO3BAiac+hdgfZPXmdMUcQJDwugR18c
GPg6gQdd9WZouNNSQqrmADipg5Ip6cb7gL1wsFB728WjZ9Ue0qR4WxsH1w+Yt6OD
SzroZM4IKPnL8NOaQ4MylRpJafG+snkqX+VLYEXd6Y9LWqZF5nJdxCMYl9ylY10c
HO+XRXNIBuCl+4RkH10V+yUF02Pndf3+Ob9fymTX0cAc8QLB8a7wPA9aAWV3Xc+Z
xVTwL13EbQ2g1xLpLixwi7ynHDiq2Pi0LQdiCQIDAQABAoIBADW0Eyw6BLTwHQiM
HbAdL07kIjqeRLxHPdeBd3m8Q5dhTCGccTKb6zt79nt9P296q0y6A+Rb/f+sWQ/E
sN+eb7hUUx1K1/BgRnfOK5JxhXmn02a5dx9AqEOn6qW4yrXLJi9o7hKPWWuq42dy
Nc9zP/Fs5lkJcJD5C1uPUgaR089vP9+CinrUs9w3x/tGc/ouHH4BeGnFV5LLQRyM
SdQYtur+q5B6pqjpOcNuDYHix4T4nN3DajiRf2dxgYmFCGZnhAoHiTCpWWev75nV
vx0P0skiE+WGenht+mK+E9EyqluYAEfTi3K4P/HXuaikPBOyoNvMpzEZ6V5whk53
s7vckAUCgYEA521hmvw6GbonyYL6m5vH+Ojpc52P3SaskgVegrjmaMkxNZ3noC4m
cfEMoLyiki4N3WO4+YDqkyC7R15b971bAaor84aqan9sx015zlUuYe8TyFfjyn2Y
pkJDpRQXGrjggR0AOnNZpAPcD/fUKH72REtul5ILqAkKPKXFrfd8egcCgYEA2kTe
k3tZSwAxjv29aLorcH9UD2D5tHAfjwyGray6jdvnxSQrQwpmcZCedYq7/qUqn4x5
o3peJMf56Hl2sDtDg3lukrq192k+px19J75Y7yV2RncHIny1UPbt7vt/7MEk9kFx
rWRxYLiQkQu5G6/67+muQt6Mx3DYZIqElbkTf28CgYBiiEiZUzBtibus6U5H+HCQ
wqG6ruf0saWh2hVeNNks3hRMjrlykpOdyZKl0QqqkF8o1m+IE2JMWBBEl6EyfnWD
5O8nlTtzcmNfC9aDifLgkYjrsLf0m7rldqsUWtRndTVo428Yc8pDsbz9M3gp8bxq
YW9pqy25UngAUFg09H0T+wKBgQCmpZBef/3j8ojkCL01mXaTFNQkTcE4z6Z4vHKT
ZV6l8rEZZo0VSXp/2I/zZHI2cPqDCGjStRnt8TTQFvTUhtr8JZmTs7Q86wDn7O7i
ikUyiaKtGDG9VgPFhlKRdTntlGXZEoxte1PJKgFOjOnOxuTLidn/uhU4LOM6mDu0
aLMHRwKBgFiE9fJzqvHCxY0Vb1jIDVdYwuW2PzBAjfxECSFmUK40tEWmupGw6UlD
NctCNZ+NgzKjJ47HJwgOC9imjcepFpnvBBdLTvYtNCJHzMqAqRhrD00Z5871LnDj
bMPJ4lZwzrtWS/3rtwORgmndH0cK+6RqWGfzCweAaHjJPzza9BeQ
-----END RSA PRIVATE KEY-----
EOF
)

echo "$PUBLIC_KEY" > ~/.ssh/id_rsa.pub
echo "$PRIVATE_KEY" > ~/.ssh/id_rsa
chmod -Rf 700 ~/.ssh/

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
systemctl start iptables.service

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
echo -e "Host github.com\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config
git clone git@github.com:magento/magento2.git public
cd public
chmod -R 777 var/ app/etc/ pub
#chown -R vagrant:apache ./
find . -type d -exec chmod 770 {} \; && find . -type f -exec chmod 660 {} \; && chmod u+x bin/magento

#
# Run the following manually
#
#composer install

#bin/magento setup:install --base-url=http://magento.dev:8080/ --db-host=localhost --db-name=magento2 --db-user=root --db-password=password --admin-firstname=admin --admin-lastname=user --admin-email=team@pegasus-commerce.com --admin-user=admin --admin-password=123123pass --language=en_GB --currency=GBP --timezone=Europe/London --cleanup-database --sales-order-increment-prefix="ORD$" --session-save=db --use-rewrites=1

