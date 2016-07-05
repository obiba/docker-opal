#
# Opal Dockerfile
#
# https://github.com/obiba/docker-opal
#

# Pull base image
FROM java:8

MAINTAINER OBiBa <dev@obiba.org>

# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.7
RUN set -x \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
	&& gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
	&& rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu \
	&& gosu nobody true

ENV LANG C.UTF-8
ENV LANGUAGE C.UTF-8
ENV LC_ALL C.UTF-8

ENV OPAL_ADMINISTRATOR_PASSWORD=password
ENV OPAL_HOME=/srv
ENV JAVA_OPTS="-Xms1G -Xmx2G -XX:MaxPermSize=256M -XX:+UseG1GC"

# Install Opal
RUN \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y apt-transport-https && \
  wget -q -O - https://pkg.obiba.org/obiba.org.key | apt-key add - && \
  echo 'deb https://pkg.obiba.org unstable/' | tee /etc/apt/sources.list.d/obiba.list && \
  echo opal opal-server/admin_password select password | debconf-set-selections && \
  echo opal opal-server/admin_password_again select password | debconf-set-selections && \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y opal opal-python-client

RUN chmod +x /usr/share/opal/bin/opal

COPY bin /opt/opal/bin
COPY data /opt/opal/data

RUN chmod +x -R /opt/opal/bin
RUN chown -R opal /opt/opal

VOLUME /srv

# http
EXPOSE 8080

# Define default command.
COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["app"]


