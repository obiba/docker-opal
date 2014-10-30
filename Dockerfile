#
# Opal Dockerfile
#
# https://github.com/obiba/docker-opal
#

# Pull base image
FROM dockerfile/java:oracle-java8

MAINTAINER OBiBa <dev@obiba.org>

# Install Opal
RUN \
  wget -q -O - http://pkg.obiba.org/obiba.org.key | sudo apt-key add - && \
  echo 'deb http://pkg.obiba.org unstable/' | sudo tee /etc/apt/sources.list.d/obiba.list && \
  echo opal opal-server/admin_password select password | sudo debconf-set-selections && \
  echo opal opal-server/admin_password_again select password | sudo debconf-set-selections && \
  apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y opal opal-python-client

COPY bin /opt/opal/bin
COPY data /opt/opal/data

RUN chmod +x -R /opt/opal/bin

# Define default command.
ENTRYPOINT ["bash", "-c", "/opt/opal/bin/start.sh"]

# https
EXPOSE 8443
# http
EXPOSE 8080