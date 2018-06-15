#!/bin/bash
#yum
wget -O /etc/yum.repos.d/Centos-6.repo http://mirrors.aliyun.com/repo/Centos-6.repo
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-6.repo
yum -y install wget vim telnet numactl libaio nmap wget vim 
#mkdir

mkdir -p /server/scripts/
mkdir -p /server/tools/
mkdir /application/
#软连接或赋值程序到PATH族目录中
#如果预设id被占用则提醒，否则提示是否更换mysql用户预设id

#设置默认端口为3306，默认已3306为一级实例子目录目录
PORT=3306
preid=1000
groupadd -g $preid  mysql && useradd -g mysql -u $preid -s /sbin/nologin mysql
#下载与解压
wget -O /server/tools/mysql-5.6.40.tar.gz  https://cdn.mysql.com//Downloads/MySQL-5.6/mysql-5.6.40-linux-glibc2.12-x86_64.tar.gz
tar xf /server/tools/mysql-5.6.40.tar.gz
find /server/tools -maxdepth 1 -type d -name "mysql*"|xargs -i mv {} /application/mysql-5.6.40
ln -s /application/mysql-5.6.40 /application/mysql
 
lost_some_depends= = [ -s /application/mysql/bin/ ] && /usr/bin/ldd /application/mysql/bin/* |grep not|grep -v dynamic|/usr/bin/wc -l ||  echo install_error
#确认动态调用库依赖正常设置
if [ $lost_some_depends -eq 0  ] ;then
	
	ln -s /application/mysql/bin/* /usr/local/bin/
    echo start setup mysqldata dirs
fi

mkdir -p /mysqldata/3306/data/
chown mysql.mysql -R /mysqldata/
#是否应该先赋值目录名字《--datadir 以及 dir
#复制或生成my.cnf
SOCKET=
PATHERRORLOG=
DATADIR=/mysqldata/$PORT/data/
DEFAULTSFLIE=/mysqldata/$PORT/my.cnf
#设置 数据库主库 预设主库id
#确认主库binlog功能打开

#初始化
/application/mysql/scripts/mysql_install_db --user=mysql --basedir=/application/mysql/ --datadir=$DATADIR --defaults-file=$DEFAULTSFLIE
###!!!!!重要需要touch出errorlog，否则不能启动

#复制启动脚本目录 或/etc/init.d/ mysql为prefix 后跟端口号
#启动mysql实例
#import
#reconfig read write count

#dump with masterdata










