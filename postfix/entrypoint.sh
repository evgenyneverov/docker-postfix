#!/bin/sh

if [ ! -f /etc/sasl2/smtpd.conf ]
then
  >&2 echo "Looks like you're not inside Docker container"
  exit 1;
fi

echo "Setting up Postfix for hostname $1"

postconf -e myhostname="$1"
postconf -e mydestination="localhost"
postconf -e mynetworks_style="host"
postconf -e maillog_file="/var/log/maillog"
echo "$1" > /etc/mailname

if [ ${#@} -gt 1 ]
then
  echo "Adding users for authorization in Postfix via sasl2"

  i=0
  for ARG in "$@"
  do
    if [ $i -gt 0 ] && [ "$ARG" != "${ARG/://}" ]
    then
      USER=`echo "$ARG" | cut -d":" -f1`
      echo "    New user: $USER"
      adduser -D -s /bin/bash $USER
      echo "$ARG" | chpasswd
      if [ ! -d /var/spool/mail/$USER ]
      then
        mkdir /var/spool/mail/$USER
      fi
      chown -R $USER:mail /var/spool/mail/$USER
      chmod -R a=rwx /var/spool/mail/$USER
      chmod -R o=- /var/spool/mail/$USER
    fi

    i=`expr $i + 1`
  done
fi

postconf -e smtpd_sasl_local_domain="$1"
postconf -e milter_default_action="accept"
postconf -e milter_protocol="2"
postconf -e smtpd_milters="inet:opendkim:8891"
postconf -e non_smtpd_milters="inet:opendkim:8891"

if env | grep '^POSTFIX_RAW_CONFIG_'
then
  echo -e "\n## POSTFIX_RAW_CONFIG ##\n" >> /etc/postfix/main.cf
  env | grep '^POSTFIX_RAW_CONFIG_' | while read I_CONF
  do
    CONFD_CONF_NAME=$(echo "$I_CONF" | cut -d'=' -f1 | sed 's/POSTFIX_RAW_CONFIG_//g')
    CONFD_CONF_VALUE=$(echo "$I_CONF" | sed 's/^[^=]*=//g')

    echo "${CONFD_CONF_NAME} = ${CONFD_CONF_VALUE}" >> /etc/postfix/main.cf
  done
fi

saslauthd -a shadow -n 2

postfix -c /etc/postfix start

tail -F /var/log/maillog
