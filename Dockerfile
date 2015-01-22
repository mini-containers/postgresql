FROM       mini/base
MAINTAINER Luis Lavena <luislavena@gmail.com>

ENV POSTGRESQL_VERSION 9.3.5-r1

# override default repositories and use latest stable one
RUN \
  apk-install postgresql=$POSTGRESQL_VERSION pwgen \
  --repositories-file /dev/nul \
  --repository http://nl.alpinelinux.org/alpine/v3.1/main

RUN mkdir -p /etc/postgresql
ADD ./config /etc/postgresql
ADD ./scripts/start.sh /start.sh

VOLUME ["/data"]

EXPOSE 5432

CMD ["/start.sh"]
