#!/bin/bash


MYSQL_HOST=127.0.0.1
MYSQL_PORT=3306
MYSQL_ROOT_PASSWORD=correcthorsebatterystaple

mysql -h $MYSQL_HOST -P$MYSQL_PORT -u root -p$MYSQL_ROOT_PASSWORD
