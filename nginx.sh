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
