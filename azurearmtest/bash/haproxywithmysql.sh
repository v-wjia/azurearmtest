#!/bin/bash

MYCNFTEMPLATE=${1}
ROOTPWD=${2}
MOUNTPOINT="/opt"

install_mysql_centos() {
    rpm -qa |grep MySQL-server-5.6.26-1.el6.x86_64
    if [ ${?} -eq 0 ];
    then
        return
    fi
    echo "installing mysql"
    wget https://dev.mysql.com/get/Downloads/MySQL-5.6/MySQL-5.6.26-1.el6.x86_64.rpm-bundle.tar
    tar -xvf MySQL-5.6.26-1.el6.x86_64.rpm-bundle.tar
	curlib=$(rpm -qa |grep mysql-libs-)
    rpm -e --nodeps $curlib
    rpm -ivh MySQL-server-5.6.26-1.el6.x86_64.rpm
    rpm -ivh MySQL-client-5.6.26-1.el6.x86_64.rpm
	wget http://dev.mysql.com/get/Downloads/Connector-Python/mysql-connector-python-2.0.4-1.el6.noarch.rpm
	rpm -ivh mysql-connector-python-2.0.4-1.el6.noarch.rpm
	wget http://dev.mysql.com/get/Downloads/MySQLGUITools/mysql-utilities-1.5.5-1.el6.noarch.rpm
	rpm -ivh mysql-utilities-1.5.5-1.el6.noarch.rpm
    yum -y install xinetd
}

create_mycnf() {
    wget "${MYCNFTEMPLATE}" -O /etc/my.cnf
}

configure_mysql() {
    /etc/init.d/mysql status
    if [ ${?} -eq 0 ];
    then
       return
    fi

    mkdir "${MOUNTPOINT}/mysql"
    ln -s "${MOUNTPOINT}/mysql" /var/lib/mysql
    chmod o+x /var/lib/mysql
    groupadd mysql
    useradd -r -g mysql mysql
    chmod o+x "${MOUNTPOINT}/mysql"
    chown -R mysql:mysql "${MOUNTPOINT}/mysql"


    install_mysql_centos

    create_mycnf
    /etc/init.d/mysql start
    mysql_secret=$(awk '/password/{print $NF}' ${HOME}/.mysql_secret)
    mysqladmin -u root --password=${mysql_secret} password ${ROOTPWD}
if [ ${NODEID} -eq 1 ];
then
    mysql -u root -p"${ROOTPWD}" <<EOF
SET PASSWORD FOR 'root'@'127.0.0.1' = PASSWORD('${ROOTPWD}');
SET PASSWORD FOR 'root'@'::1' = PASSWORD('${ROOTPWD}');
CREATE USER 'admin'@'%' IDENTIFIED BY '${ROOTPWD}';
GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' with grant option;
FLUSH PRIVILEGES;
EOF
fi

}

configure_mysql

chkconfig httpd on