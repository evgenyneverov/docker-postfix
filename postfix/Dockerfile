FROM alpine:3.21.0

ADD ./entrypoint.sh /

RUN apk add postfix tzdata cyrus-sasl && apk cache clean; \
    ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime; \
    echo "Europe/Moscow" > /etc/timezone; \
    mkdir /etc/sasl2; \
    echo 'log_level: 3' > /etc/sasl2/smtpd.conf; \
    echo 'pwcheck_method: saslauthd' >> /etc/sasl2/smtpd.conf; \
    echo 'mech_list: plain login' >> /etc/sasl2/smtpd.conf; \
    echo "saslauthd_path: /var/run/saslauthd/mux" >> /etc/sasl2/smtpd.conf; \
    postconf -e smtpd_banner="\$myhostname ESMTP"; \
    postconf -e mail_spool_directory="/var/spool/mail/"; \
    postconf -e mailbox_command="";\
    postconf -e smtpd_sasl_auth_enable="yes"; \
    postconf -e smtp_tls_security_level="may"; \
    postconf -e smtpd_recipient_restrictions="permit_sasl_authenticated, reject_non_fqdn_sender, reject_unknown_sender_domain, reject_unknown_recipient_domain, permit_mynetworks, reject_unauth_destination, reject_non_fqdn_hostname, reject_invalid_hostname, permit"; \
    postconf -e smtpd_client_restrictions="permit_sasl_authenticated, reject_unauth_pipelining, reject"; \
    postcnof -e smtpd_data_restrictions="reject_multi_recipient_bounce"; \
    adduser -s /sbin/nologin -D -H sasl; \
    chmod a+x /entrypoint.sh

EXPOSE 25

ENTRYPOINT ["/entrypoint.sh"]
CMD ["tech-director.ru", "bx:abc"]
