#!/bin/bash

. /etc/rc.d/init.d/functions

[[ $# -eq 0 ]] && {
  echo "usage: $0 start|stop|restart"
  exit 0
}

case $1 in
  start)
    /usr/local/mysql3306/bin/mysqld  --defaults-file=/etc/mysql3306.cnf & &> /dev/null
    [[ -n $(ps -ef | grep mysqld | grep -v grep) ]] && {
        action "MySQL Started..." /bin/true
    } || {
        action "MySQL Start Failed" /bin/false
    }
    ;;
  stop)
    /usr/local/mysql3306/bin/mysqladmin -u root -pxxxxxxxx -S /data/mysql/3306/mysql.sock shutdown &> /dev/null;
    sleep 2;
    [[ ! -n $(ps -ef | grep mysqld | grep -v grep) ]] && {
        action "MySQL Stoped" /bin/true
    }
    ;;
  restart)
    /usr/local/mysql3306/bin/mysqladmin -u root -pxxxxxxxx -S /data/mysql/3306/mysql.sock shutdown &> /dev/null;
    sleep 2;
    /usr/local/mysql3306/bin/mysqld --defaults-file=/etc/mysql3306.cnf & &> /dev/null
    [[ -n $(ps -ef | grep mysqld | grep -v grep) ]] && {
        action "MySQL Restarted..." /bin/true
    } || {
        action "MySQL Restart Failed" /bin/false
    }
    ;;
  *)
    echo "Wrong Input"
    echo "usage: $0 start|stop|restart"
esac
exit 0
