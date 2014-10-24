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
  apt-get update && apt-get install -y opal opal-python-client

#RUN echo JAVA_ARGS=\"\$JAVA_ARGS -DMONGODB_PORT=\$MONGODB_PORT\" >> /etc/default/opal

# Define mountable directories.
VOLUME ["/data/opal"]

# Define working directory.
WORKDIR /data

# Define default command.
CMD ["service", "opal", "start"]

# https
EXPOSE 8443