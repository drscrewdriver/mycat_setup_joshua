MIN=`date '+%Y-%m-%d %H-%M'`
#LINKCOUNT=`ss -at|grep -v LISTEN|grep http| wc -l`
LOGPATH=/var/log/nginx_link.log
for i in `seq 60`;
  do count[$i]=`ss -at|grep -v LISTEN|grep http| wc -l`;
	sleep 1;
done
LINKCOUNT=$(for i in `seq 60`;do echo ${count[$i]};done|sort|tail -1)
echo $LINKCOUNT	


echo $MIN    linkcount is : $LINKCOUNT >>$LOGPATH
