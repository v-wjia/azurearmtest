#!/bin/bash

rpm -ivh http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm

config="
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/OS/OSRELEASE/$basearch/
gpgcheck=0
enabled=1
"

#echo "$config" > /etc/yum.repos.d/nginx.repo
yum check-update
yum -y install nginx

service nginx start
chkconfig nginx on

#startip=$1
#nodeip=$2

sed -i '1 a\
/server {/upstream myserver {\
server 10.0.2.20:80;\
server 10.0.2.21:80;\
}' /etc/nginx/conf.d/nginx.conf

sed -i '14/root   /usr/share/nginx/html;/#root   /usr/share/nginx/html;/' /etc/nginx/conf.d/nginx.conf
sed -i '15/index  index.html index.htm;/#index  index.html index.htm;/' /etc/nginx/conf.d/nginx.conf

sed -i '16 a\
proxy_pass http://myServer;' /etc/nginx/conf.d/nginx.conf