FROM       mini/base
MAINTAINER Luis Lavena <luislavena@gmail.com>

ENV POSTGRESQL_VERSION 9.3.5-r0

RUN apk-install postgresql=$POSTGRESQL_VERSION pwgen

RUN mkdir -p /etc/postgresql
ADD ./config /etc/postgresql
ADD ./scripts/start.sh /start.sh

VOLUME ["/data"]

EXPOSE 5432

CMD ["/start.sh"]
