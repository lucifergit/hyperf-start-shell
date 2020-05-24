#!/bin/bash

doFlag=$1
SERVER=`pwd`
source $SERVER/.env
APPNAME=$APP_NAME
PIDPATH=$SERVER/runtime/hyperf.pid
MASTERAPP=$APPNAME.Master
cd $SERVER

start(){
	echo "start service..."
	if [ ! -f $PIDPATH ]; then
		startone
	else
		echo "pid existed"
		stopone
		startone
	fi
	echo "start service completed!"	    
}

startone(){
	nohup php bin/hyperf.php start > $SERVER/runtime/log.out 2>&1 &
	#nohup php bin/hyperf.php start > /dev/null 2>&1 &
	tail -f $SERVER/runtime/log.out
}

stopone(){
	echo "stop service..."
	kill `cat $PIDPATH`
	rm -rf $PIDPATH
	sleep 2
	echo "stop service $APPNAME completed!"
}

stop(){
  echo "stop $MASTERAPP service..."
  ps -ef | grep $MASTERAPP | grep -v grep | awk '{print $2}' | xargs kill -9 2>&1
  rm -rf $PIDPATH
  sleep 2
	echo "stop service $APPNAME completed!"
}

startdev(){
  #监听文件变化自动重启Hyperf
  #依赖https://github.com/ha-ni-cc/hyperf-watch 下载单文件watch到根目录 根据情况修改扫描间隔
	if [ ! -f watch ]; then
		echo -e  "依赖https://github.com/ha-ni-cc/hyperf-watch 下载单文件watch到根目录"
		exit 1
	fi
  echo "start $MASTERAPP service dev..."
	nohup php watch -c > $SERVER/runtime/log.out 2>&1 &
	tail -f $SERVER/runtime/log.out
}

restart()
{
    stop
    sleep 2
    startone
}

status()
{
    PID=`ps -ef |grep $MASTERAPP|grep -v grep|wc -l`
    if [ $PID != 0 ];then
        echo "$AppName is running..."
    else
        echo "$AppName is not running..."
    fi
}


if [ "$doFlag" = "" ];
then
    echo -e "\033[0;31m 未输入操作名 \033[0m  \033[0;34m {start|stop|stopone|watchstart|restart|status} \033[0m"
    exit 1
fi

case $doFlag in
    start)
    start;;
    startone)
    startone;;
    stopone)
    stopone;;
    stop)
    stop;;
    startdev)
    startdev;;
    restart)
    restart;;
    status)
    status;;
    *)
esac
