FROM alpine:3.21.0

RUN apk add opendkim tzdata && apk cache clean; \
    ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime; \
    echo "Europe/Moscow" > /etc/timezone; \
    mkdir /run/opendkim

ADD ./conf/ /etc/opendkim/
ADD ./entrypoint.sh /

EXPOSE 8891

#ENTRYPOINT ["/bin/sh"]
#CMD ["/entrypoint.sh"]

CMD ["opendkim", "-f", "-A", "-vvvv", "-W"]
