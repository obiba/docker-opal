#
# Opal Dockerfile
#
# https://github.com/obiba/docker-opal
#

# Pull base image
FROM java:8

MAINTAINER OBiBa <dev@obiba.org>

ENV LANG C.UTF-8
ENV LANGUAGE C.UTF-8
ENV LC_ALL C.UTF-8

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

COPY bin /opt/opal/bin
COPY data /opt/opal/data

RUN chmod +x -R /opt/opal/bin

ENV OPAL_ADMINISTRATOR_PASSWORD=password

# Define default command.
ENTRYPOINT ["/opt/opal/bin/start.sh"]

# https and http
EXPOSE 8443 8080
