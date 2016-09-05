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

sed -i "s#server {#upstream myserver {#g" /etc/nginx/conf.d/default.conf
sed -i '1 a\
server 10.0.2.20:80;\
server 10.0.2.21:80;\
}' /etc/nginx/conf.d/default.conf

sed -i '4 a\
server {' /etc/nginx/conf.d/default.conf

sed -i "s#root   /usr/share/nginx/html;#proxy_pass http://myServer;#g" /etc/nginx/conf.d/default.conf
sed -i "s#index  index.html index.htm;# #g" /etc/nginx/conf.d/default.conf

service nginx restart