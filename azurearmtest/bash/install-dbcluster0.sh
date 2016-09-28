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

cd /root/package/

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
    user        root
    group       root
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
    server mysql1 10.157.59.15:3307 check
    server mysql2 10.157.59.16:3307 backup
"

ln -f -s /usr/local/haproxy/sbin/haproxy /usr/sbin/

cp -f examples/haproxy.init /etc/init.d/haproxy
chmod +x /etc/init.d/haproxy

if [ ! -d "/etc/haproxy" ]; then
	mkdir /etc/haproxy
fi
echo "$haProxyConfig" > /etc/haproxy/haproxy.cfg

service haproxy start


#########################
# keepalived
#########################
echo ""
echo ""
echo "begin instll keepalived ------------------------------- "

if [ ! -d "/usr/include/openssl/" ]; then
	echo "openssl develop kit not exist, yum will install"
	yum -y install openssl-devel.x86_64
fi

cd /root/package/
tar zxvf keepalived-1.2.23.tar.gz
cd keepalived-1.2.23
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
        chk_haproxy #监测haproxy进程状态
    }
    virtual_ipaddress {
        10.1.0.222
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
        10.1.0.223          
    }
}
"

cp /usr/local/keepalived/sbin/keepalived /usr/sbin/
cp /usr/local/keepalived/etc/sysconfig/keepalived /etc/sysconfig/
cp /usr/local/keepalived/etc/rc.d/init.d/keepalived /etc/init.d/
mkdir /etc/keepalived
cp /usr/local/keepalived/etc/keepalived/keepalived.conf  /etc/keepalived/

if [ ! -d "/etc/keepalived" ]; then
	mkdir /etc/keepalived
fi
echo "$keepalivedConfig" > /etc/keepalived/keepalived.conf

service keepalived start
