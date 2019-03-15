#!/bin/sh

if md5sum -c /var/log/check_crontab.log; then
	echo "/etc/crontab unchanged" | mail -s "asd" root
else
	echo "/etc/crontab was modified" | mail -s "/etc/crontab was modified" root
fi
md5sum /etc/crontab > /var/log/check_crontab.log
