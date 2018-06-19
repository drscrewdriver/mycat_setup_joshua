mport
IMPORTSQL=null.sql
$CMDPATH/mysql -S $SOCKET -uroot <${IMPORTSQL}

#reconfig read write count
$CMDPATH/mysql  -S $SOCKET -uroot -e ""

#dump with masterdata

