#!/bin/bash

# DEPS: /usr/sbin/pflogsumm
# DEPS: pygtail.py

MAILLOG=/var/log/mail.log
FPOS=/tmp/zabbix-postfix-offset.dat
PFLOGSUMM=/usr/sbin/pflogsumm
LOGTAIL=/usr/local/sbin/pygtail.py
ZABBIX_CONF=/etc/zabbix/zabbix_agentd.conf

function zsend {
  /usr/bin/zabbix_sender -c $ZABBIX_CONF -k $1 -o $2
}

DATA="$(${LOGTAIL} -o ${FPOS} ${MAILLOG} | ${PFLOGSUMM} -h 0 -u 0 --bounce_detail=0 --deferral_detail=0 --reject_detail=0 --no_no_msg_size --smtpd_warning_detail=0)"

zsend zimbra.pf.received $(echo -e "${DATA}" | grep -m 1 received | cut -f1 -d"r")
zsend zimbra.pf.delivered $(echo -e "${DATA}" | grep -m 1 delivered | cut -f1 -d"d")
zsend zimbra.pf.forwarded $(echo -e "${DATA}" | grep -m 1 forwarded | cut -f1 -d"f")
zsend zimbra.pfdeferred $(echo -e "${DATA}" | grep -m 1 deferred | cut -f1 -d"d")
zsend zimbra.pf.bounced $(echo -e "${DATA}" | grep -m 1 bounced | cut -f1 -d"b")
zsend zimbra.pf.rejected $(echo -e "${DATA}" | grep -m 1 rejected | cut -f1 -d"r")
zsend zimbra.pf.rejectwarnings $(echo -e "${DATA}" | grep -m 1 "reject warnings" | cut -f1 -d"r")
zsend zimbra.pf.held $(echo -e "${DATA}" | grep -m 1 held | cut -f1 -d"h")
zsend zimbra.pf.discarded $(echo -e "${DATA}" | grep -m 1 discarded | cut -f1 -d"d")
zsend zimbra.pf.bytesreceived $(echo -e "${DATA}" | grep -m 1 "bytes received" | cut -f1 -d"b")
zsend zimbra.pf.bytesdelivered $(echo -e "${DATA}" | grep -m 1 "bytes delivered" | cut -f1 -d"b")

