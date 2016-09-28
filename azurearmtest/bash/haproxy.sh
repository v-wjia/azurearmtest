#!/bin/bash


wget https://armresstorage.blob.core.chinacloudapi.cn/script/haproxy-1.6.9.tar.gz -O ~/haproxy.tar.gz
tar xzvf ~/haproxy.tar.gz -C ~/
cd ~/haproxy-1.6.9
make TARGET=linux2628
make install

#To complete the install, use the following commands to copy the settings over.
sudo cp /usr/local/sbin/haproxy /usr/sbin/
sudo cp ~/haproxy-1.6.9/examples/haproxy.init /etc/init.d/haproxy
sudo chmod 755 /etc/init.d/haproxy

#Create these directories and the statistics file for HAProxy to record in.
sudo mkdir -p /etc/haproxy
sudo mkdir -p /run/haproxy
sudo mkdir -p /var/lib/haproxy
sudo touch /var/lib/haproxy/stats


sudo useradd -r haproxy
# user, group, mysql should be changed
haProxyConfig="global
    # to have these messages end up in /var/log/haproxy.log you will
    # need to:
    #
    # 1) configure syslog to accept network log events.  This is done
    #    by adding the '-r' option to the SYSLOGD_OPTIONS in
    #    /etc/sysconfig/syslog
    #
    # 2) configure local2 events to go to the /var/log/haproxy.log
    #   file. A line like the following can be added to
    #   /etc/sysconfig/syslog
    #
    #    local2.*                       /var/log/haproxy.log
    #
    log         127.0.0.1 local2

    #chroot      /var/lib/haproxy
    chroot      /usr/local
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon

    # turn on stats unix socket
    #stats socket /var/lib/haproxy/stats

#---------------------------------------------------------------------
# common defaults that all the 'listen' and 'backend' sections will
# use if not designated in their block
#---------------------------------------------------------------------
defaults
    log                     global
    retries                 2
    mode                    tcp
    option                  dontlognull
    option                  redispatch
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout check           10s

listen mysql_cluster
    bind *:3306
    mode tcp
    timeout client 1m
    timeout server 1m
    balance roundrobin
    option tcp-check
    tcp-check expect string is running.
    server mysql1 10.0.4.4:3306 check
    server mysql2 10.0.4.5:3306 backup
"
echo "$haProxyConfig" > /etc/haproxy/haproxy.cfg

service haproxy start
chkconfig haproxy on

#keepalived
yum -y install openssl-devel.x86_64
wget http://www.keepalived.org/software/keepalived-1.2.20.tar.gz -O ~/keepalived.tar.gz
tar xzvf ~/keepalived.tar.gz -C ~/
cd ~/keepalived-1.2.20
./configure --prefix=/usr/local/keepalived
make
make install
keepalivedConfig="
! Configuration File for keepalived

global_defs {
   router_id LVS_DEVEL
}
vrrp_script chk_haproxy {
    script "/usr/local/keepalived/check_haproxy.sh"
    interval 2
    weight 2
}
vrrp_instance VI_1 {
    state MASTER
    interface eth0
    virtual_router_id 51
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 5555
    }
    track_script {
        chk_haproxy #¼à²âhaproxy½ø³Ì×´Ì¬
    }
    virtual_ipaddress {
        10.0.3.4
    }
}
vrrp_instance VI_2 {
    state BACKUP
    interface eth0
    virtual_router_id 52
    priority 99
    advert_int 1
    authentication {
         auth_type PASS
         auth_pass 1111
    }
    virtual_ipaddress {
        10.0.3.5          
    }
}
"

cp /usr/local/keepalived/sbin/keepalived /usr/sbin/
cp /usr/local/keepalived/etc/sysconfig/keepalived /etc/sysconfig/
cp /usr/local/keepalived/etc/rc.d/init.d/keepalived /etc/init.d/
mkdir /etc/keepalived
cp /usr/local/keepalived/etc/keepalived/keepalived.conf  /etc/keepalived/

if [ ! -d "/etc/keepalived" ]; then
	mkdir /etc/keepalived
fi
echo "$keepalivedConfig" > /etc/keepalived/keepalived.conf

service keepalived start
chkconfig keepalived on