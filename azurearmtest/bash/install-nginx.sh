#!/bin/bash

webid=$1
wechatNum=$2
wechatStartIP=$3

serverip=""
startipprefix=${wechatStartIP:0:6}
startip=${wechatStartIP:7:2}

for((i=1; i<=$wechatNum; i++))
do
serverip+="server $startipprefix.$startip:80;"
startip=$((startip+1))
echo $serverip
done

wget https://armresstorage.blob.core.chinacloudapi.cn/script/nginx-release-centos-6-0.el6.ngx.noarch.rpm
rpm -ivh nginx-release-centos-6-0.el6.ngx.noarch.rpm

config="
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/OS/OSRELEASE/$basearch/
gpgcheck=0
enabled=1
"

yum check-update
yum -y install nginx

service nginx start
chkconfig nginx on

sed -i "s#server {#upstream myserver {#g" /etc/nginx/conf.d/default.conf
sed -i "1 a\
server $webip1:80;\
server $webip2:80;\
}" /etc/nginx/conf.d/default.conf

sed -i '2 a\
server {' /etc/nginx/conf.d/default.conf

sed -i "s#root   /usr/share/nginx/html;#proxy_pass http://myServer;#g" /etc/nginx/conf.d/default.conf
sed -i "s#index  index.html index.htm;# #g" /etc/nginx/conf.d/default.conf

service nginx restart