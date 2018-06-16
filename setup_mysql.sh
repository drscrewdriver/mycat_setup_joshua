#!/bin/bash
#yum yum源预设
#pre
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-6.repo
yum -y install wget vim telnet numactl libaio nmap wget vim 
#mkdir
mkdir -p /server/scripts/
mkdir -p /server/tools/
mkdir /application/


#变量和预设

#如果预设id被占用则提醒，否则提示是否更换mysql用户预设id

#设置默认端口为3306，默认已3306为一级实例子目录目录
PORT=3306
preid=1000
#用户添加
groupadd -g ${preid}  mysql && useradd -g mysql -u ${preid} -s /sbin/nologin mysql
#下载与解压
wget -O /server/tools/mysql-5.6.40.tar.gz  https://cdn.mysql.com//Downloads/MySQL-5.6/mysql-5.6.40-linux-glibc2.12-x86_64.tar.gz
tar xf /server/tools/mysql-5.6.40.tar.gz
find /server/tools -maxdepth 1 -type d -name "mysql*"|xargs -i mv {} /application/mysql-5.6.40
#软连接或赋值程序到PATH族目录中
ln -s /application/mysql-5.6.40 /application/mysql
#目录权限
chown mysql.mysql -R /application/mysql*
 
lost_some_depends= = [ -s /application/mysql/bin/ ] && /usr/bin/ldd /application/mysql/bin/* |grep not|grep -v dynamic|/usr/bin/wc -l ||  echo install_error
#确认动态调用库依赖正常设置
if [ ${lost_some_depends} -eq 0  ] ;then
	
	ln -s /application/mysql/bin/* /usr/local/bin/
    echo start setup mysqldata dirs
fi

#数据实例设置
chown mysql.mysql -R /mysqldata/
#是否应该先赋值目录名字《--datadir 以及 dir

DATADIR=/mysqldata/$PORT/data/
mkdir -p ${DATADIR}


#复制或生成my.cnf
CMDPATH=/application/mysql/bin/
DATADIRBASE=/mysqldata/${PORT}/
SOCKET=/mysqldata/${PORT}/mysql.sock
PATHERRORLOG=/mysqldata/${PORT}/mysqlerror-${PORT}.log
DEFAULTSFLIE=/mysqldata/${PORT}/my.cnf
DBID=10
MAXCON=4096
MYSQL_MSCRIPT=/etc/init.d/mysql-${PORT}
#设置 数据库主库 预设主库id
#确认主库binlog功能打开
cat <<EOF >${DEFAULTSFLIE}
[client]
port            = ${PORT}
socket          = ${SOCKET}
[mysql]
prompt="(\\u@\\h) [\\d]>\\_\\r:\\m:\\s>"
EOF
cat <<EOF >>${DEFAULTSFLIE}
[mysqld]
datadir=${DATADIR}
user    = mysql
port    = ${PORT}
basedir = /application/mysql
open_files_limit = 65535
socket=${SOCKET}
#default utf-8
default-storage-engine = innodb
collation-server = utf8_general_ci
character-set-server = utf8
innodb_file_per_table
back_log = 600
max_connections = $MAXCON
max_connect_errors = 3000
max_allowed_packet = 16M
sort_buffer_size = 4M
join_buffer_size = 4M
thread_cache_size = 1000
query_cache_size = 16M
query_cache_limit = 64M
query_cache_min_res_unit = 2k
thread_stack = 192K
tmp_table_size = 4M
max_heap_table_size = 4M
slow-query-log=1
long_query_time = 1
slow-query-log-file=/mysqldata/3306/slow.log
server-id=$DBID
log-bin = mysql-bin$PORT
binlog_cache_size = 4M
max_binlog_cache_size = 8M
max_binlog_size = 2M
expire_logs_days = 7
key_buffer_size = 32M
read_buffer_size = 16M
read_rnd_buffer_size = 16M
bulk_insert_buffer_size = 16M
symbolic-links=0
innodb_buffer_pool_size = 32M
#innodb_data_file_path = ibdata1:128M:autoextend
innodb_file_io_threads = 8
innodb_thread_concurrency = 8
innodb_flush_log_at_trx_commit = 2
innodb_log_buffer_size = 4M
innodb_log_file_size = 8M
innodb_log_files_in_group = 3
innodb_max_dirty_pages_pct = 90
innodb_lock_wait_timeout = 120
# Recommended in standard MySQL setup
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES
EOF
cat <<EOF >>${DEFAULTSFLIE}
log-error=${PATHERRORLOG}
pid-file=${DATADIRBASE}/${PORT}.pid
EOF
#初始化
/application/mysql/scripts/mysql_install_db --user=mysql --basedir=/application/mysql/ --datadir=$DATADIR --defaults-file=${DEFAULTSFLIE}
###!!!!!重要需要touch出errorlog，否则不能启动
touch ${PATHERRORLOG}
#复制启动脚本目录 或/etc/init.d/ mysql为prefix 后跟端口号
cat <<EOF >>${MYSQL_MSCRIPT}
#!/bin/sh
################################################
#this scripts is created by joshua_mysql_installer at $(date '+%Y-%m-%d')
#joshau QQ:597093681
#blog:http://www.drscrewdriver.com
################################################

function_start_mysql()
{
    if [ ! -e "${SOCKET}" ];then
      printf "Starting MySQL...\n"
     /bin/sh ${CMDPATH}/mysqld_safe --defaults-file=${DEFAULTSFLIE} 2>&1 > /dev/null &
    else
      printf "MySQL is running...\n"
      exit
    fi
}

#stop function
function_stop_mysql()
{
    if [ ! -e "${SOCKET}" ];then
       printf "MySQL is stopped...\n"
       exit
    else
       printf "Stoping MySQL...\n"
	   ${CMDPATH}/mysqladmin -uroot -S /mysqldata/${PORT}/mysql.sock shutdown
   fi
}

#restart function
function_restart_mysql()
{
    printf "Restarting MySQL...\n"
    function_stop_mysql
    sleep 2
    function_start_mysql
}

case $1 in
start)
    function_start_mysql
;;
stop)
    function_stop_mysql
;;
restart)
    function_restart_mysql
;;
*)
    printf "Usage: '$0' {start|stop|restart}\n"
esac


EOF
#执行权限
chmod +x $MYSQL_MSCRIPT
#启动mysql实例
/bin/bash $MYSQL_MSCRIPT start

#import
$CMDPATH/mysql -S $SOCKET -uroot <${IMPORTSQL}

#reconfig read write count
$CMDPATH/mysql  -S $SOCKET -uroot -e ""

#dump with masterdata










