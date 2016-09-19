#!/bin/bash
#
# install application haproxy and keepalived on Linux server
#
# specify the range:
#    source_...		-- configuration of install directory
#
# This script originally written by: SiweiLv<baihualin_hust@163.com> 
#                                    Architect Engineer, microsoft 
#                                    April 24, 2016 
#
# ---- modified by: Siweilv, April 24, 2016

#
# 0, parameter parse
#

wget https://armresstorage.blob.core.chinacloudapi.cn/script/keepalived-1.2.23.tar.gz
wget https://armresstorage.blob.core.chinacloudapi.cn/script/haproxy-1.5.4.tar.gz
echo net.ipv4.ip_nonlocal_bind = 1 >> /etc/sysctl.conf
sysctl -p

#MASTER_IP=${1}
#SLAVE_IP=${2}
NODEID=${1}

if [ ! -f "/usr/bin/gcc" ]; then
	echo "Gcc not exist, yum will install"
	yum -y install gcc.x86_64
fi

tar -zvxf haproxy-1.5.4.tar.gz
cd haproxy-1.5.4
mkdir /usr/local/haproxy
make PREFIX=/usr/local/haproxy TARGET=linux26 ARCH=x86_64
make install PREFIX=/usr/local/haproxy 




# user, group, mysql should be changed
haProxyConfig="global
    log         127.0.0.1 local2
    ulimit-n    400960
    chroot      /usr/local
    pidfile     /var/run/haproxy.pid
    maxconn     100000
    nbproc      16
    user        root
    group       root
    daemon

defaults
    mode                    tcp
    log                     global
    #option                 httplog
    #option                 dontlognull
    option                  redispatch
    option                  abortonclose
    retries                 5
    timeout http-request    60s
    timeout queue           1m
    timeout connect         10s
    timeout client          3m
    timeout server          3m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 100000

listen mysql_cluster
    bind 0.0.0.0:3306
    mode tcp
    timeout client 1m
    timeout server 1m
    balance roundrobin
    option mysql-check
    server mysql1 10.0.4.4:3306 check port 3306
    server mysql2 10.0.4.5:3306 check port 3306 backup"

ln -f -s /usr/local/haproxy/sbin/haproxy /usr/sbin/

cp -f examples/haproxy.init /etc/init.d/haproxy
chmod +x /etc/init.d/haproxy

if [ ! -d "/etc/haproxy" ]; then
	mkdir /etc/haproxy
fi
echo "$haProxyConfig" > /etc/haproxy/haproxy.cfg

service haproxy start
chkconfig haproxy on

#########################
# keepalived
#########################
#echo ""
#echo ""
#echo "begin instll keepalived ------------------------------- "

#if [ ! -d "/usr/include/openssl/" ]; then
#	echo "openssl develop kit not exist, yum will install"
#	yum -y install openssl-devel.x86_64
#fi

#cd ../

#tar zxvf keepalived-1.2.23.tar.gz
#cd keepalived-1.2.23
#./configure --prefix=/usr/local/keepalived
#make
#make install

#keepalivedConfig="
#! Configuration File for keepalived
#global_defs {
#   notification_email {
#        admin@localhost.com
#   }
#   notification_email_from admin@localhost.com
#   smtp_server smtpcloud.sohu.com
#   smtp_connect_timeout 30
#   router_id LVS_DEVEL
#}
#
#vrrp_instance VI_1 {
#    state MASTER
#    interface eth0
#    virtual_router_id 9
#    priority 200
#    advert_int 1
#    preempt
#    authentication {
#        auth_type PASS
#        auth_pass myloadblance
#    }
#    virtual_ipaddress {
#        ${VIP1_IP}
#    }
#}
#
#vrrp_instance VI_2 {
#    state BACKUP
#    interface eth0
#    virtual_router_id 10
#    priority 100
#    advert_int 1
#    preempt
#    authentication {
#        auth_type PASS
#        auth_pass myloadblance
#    }
#    virtual_ipaddress {
#        ${VIP2_IP}
#    }
#}
#"

#cp /usr/local/keepalived/sbin/keepalived /usr/sbin/
#cp /usr/local/keepalived/etc/sysconfig/keepalived /etc/sysconfig/
#cp /usr/local/keepalived/etc/rc.d/init.d/keepalived /etc/init.d/
#mkdir /etc/keepalived
#cp /usr/local/keepalived/etc/keepalived/keepalived.conf /etc/keepalived/

#if [ ! -d "/etc/keepalived" ]; then
#	mkdir /etc/keepalived
#fi
#echo "$keepalivedConfig" > /etc/keepalived/keepalived.conf

#service keepalived start
#chkconfig keepalived on