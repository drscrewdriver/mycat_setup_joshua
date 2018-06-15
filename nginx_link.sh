MIN=`date '+%Y-%m-%d %H:%M'`
LINKCOUNT=`ss -at|grep -v LISTEN|grep http| wc -l`
LOGPATH=/var/log/nginx_link.log
echo $MIN    linkcount is : $LINKCOUNT >>$LOGPATH
