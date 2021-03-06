#!/bin/bash

# disable ipv6
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1 
sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1

# vars
IPADDRESS="$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')";

# add users
adduser --system --shell /bin/false --group --disabled-login restreamer
adduser --system --shell /bin/false --group --disabled-login mini_cs
adduser --system --shell /bin/false --group --disabled-login www-data
chown -R restreamer:restreamer /home/restreamer

# set user permissions
echo "restreamer ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers
echo "mini_cs ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers
echo "www-data ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers

# update apt
sudo apt-get update

# install core apps
sudo apt install -y sysstat unzip htop nload iftop curl git libxslt1-dev nscd htop libonig-dev libzip-dev software-properties-common aria2 ufw
sudo add-apt-repository ppa:xapienz/curl34 -y
sudo apt-get update
sudo apt-get install -y libcurl4 curl
sudo dpkg -i /home/restreamer/vendors/libpng12.deb
sudo apt-get install -y
sudo apt install -qq -yy sysstat htop nload iftop curl git libxslt1-dev nscd htop libonig-dev libzip-dev software-properties-common aria2 ufw

# upgrade apt
sudo apt-get upgrade -y

# install streamlink
sudo add-apt-repository ppa:nilarimogard/webupd8 -y
sudo apt update
sudo apt-get install -y streamlink

# install mini_cs
sudo git clone http://git.genexnetworks.net/whittinghamj/widevine_drm_streamer.git /home/mini_cs
sudo chmod 777 -R /home/mini_cs
sudo chmod +x /home/mini_cs/bin/ffmpeg
sudo chmod +x /home/mini_cs/bin/mp4decrypt
sudo chmod +x /home/mini_cs/php/bin/php
sudo chmod +x /home/mini_cs/php/sbin/php-fpm
sudo chmod +x /home/mini_cs/nginx/sbin/nginx
sudo rm -rf /home/__MACOSX

# create ramfs
sudo sed -i '/home\/restreamer/d' /etc/fstab
sleep 2
sudo echo $'\ntmpfs /home/restreamer/hls tmpfs defaults,noatime,nosuid,nodev,noexec,mode=1777,size=90% 0 0' >> /etc/fstab
sudo echo $'\ntmpfs /home/mini_cs/hls tmpfs defaults,noatime,nosuid,nodev,noexec,mode=1777,size=90% 0 0' >> /etc/fstab
sudo mount -av

# install nginx + php
# mkdir -p /opt/nginx/
# cp /home/restreamer/vendors/nginx-1.15.8.tar.gz /opt/nginx
# cd /opt/nginx/
# tar -zxvf nginx-1.15.8.tar.gz
# cd nginx-1.15.8
# ./configure --prefix=/home/restreamer/nginx/ --conf-path=/home/restreamer/nginx/conf/nginx.conf --with-threads --http-client-body-temp-path=/home/restreamer/tmp/client_temp --http-proxy-temp-path=/home/restreamer/tmp/proxy_temp --http-fastcgi-temp-path=/home/restreamer/tmp/fastcgi_temp --lock-path=/home/restreamer/tmp/nginx.lock --http-uwsgi-temp-path=/home/restreamer/tmp/uwsgi_temp --http-scgi-temp-path=/home/restreamer/tmp/scgi_temp --conf-path=/home/restreamer/nginx/conf/nginx.conf --error-log-path=/home/restreamer/logs/error.log --http-log-path=/home/restreamer/logs/access.log --pid-path=/home/restreamer/nginx/nginx.pid --user=restreamer --group=restreamer
# make
# sudo make install

# open firewall ports
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443
sudo ufw allow 8080
sudo ufw allow 10810
sudo ufw allow 10811
sudo ufw allow 18000
sudo ufw allow 18001
sudo ufw allow 33077

# install crontab
sudo crontab -l > /tmp/crontab.txt
sudo echo '@reboot sh /home/restreamer/scripts/start.sh' >> /tmp/crontab.txt
sudo echo '@reboot sh /home/mini_cs/scripts/start.sh' >> /tmp/crontab.txt
sudo crontab /tmp/crontab.txt
sudo rm /tmp/crontab.txt

# output
echo " "
echo "Dashboard URL: http://"$IPADDRESS":80/"
echo " "
echo "Default login details: "
echo "Username: admin"
echo "Password: admin"
echo " "

# start restreamer
sudo sh /home/restreamer/scripts/start.sh

