#
# Mica Dockerfile
#
# https://github.com/obiba/docker-mica
#

# Pull base image
FROM openjdk:8

MAINTAINER OBiBa <dev@obiba.org>

# grab gosu for easy step-down from root
# see https://github.com/tianon/gosu/blob/master/INSTALL.md
ENV GOSU_VERSION 1.10
ENV GOSU_KEY B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN set -ex; \
  \
  fetchDeps=' \
    ca-certificates \
    wget \
  '; \
  apt-get update; \
  apt-get install -y --no-install-recommends $fetchDeps; \
  rm -rf /var/lib/apt/lists/*; \
  \
  dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
  wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
  wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
  \
# verify the signature
  export GNUPGHOME="$(mktemp -d)"; \
  gpg --keyserver pgp.mit.edu --recv-keys "$GOSU_KEY" || \
  gpg --keyserver keyserver.pgp.com --recv-keys "$GOSU_KEY" || \
  gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GOSU_KEY"; \
  gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
  rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc; \
  \
  chmod +x /usr/local/bin/gosu; \
# verify that the binary works
  gosu nobody true;

ENV LANG C.UTF-8
ENV LANGUAGE C.UTF-8
ENV LC_ALL C.UTF-8

ENV OPAL_ADMINISTRATOR_PASSWORD=password
ENV OPAL_HOME=/srv
ENV JAVA_OPTS="-Xms1G -Xmx2G -XX:MaxPermSize=256M -XX:+UseG1GC"


ENV SEARCH_ES_VERSION=1.0.0
ENV VCF_STORE_VERSION=1.0.2
ENV SAMTOOLS_VERSION=1.4
ENV OPAL_VERSION=2.12.0

# Install and build Jennnite dependencies
RUN apt-get update; \
   apt-get install -y unzip gcc make curl liblzma-dev libbz2-dev libncurses5-dev zlib1g-dev; \
   curl -L -o htslib-$SAMTOOLS_VERSION.tar.gz https://github.com/samtools/htslib/archive/$SAMTOOLS_VERSION.tar.gz ; \
   curl -L -o samtools-$SAMTOOLS_VERSION.tar.gz https://github.com/samtools/samtools/archive/$SAMTOOLS_VERSION.tar.gz ; \
   curl -L -o bcftools-$SAMTOOLS_VERSION.tar.gz https://github.com/samtools/bcftools/archive/$SAMTOOLS_VERSION.tar.gz ; \
   tar xzf bcftools-$SAMTOOLS_VERSION.tar.gz ; \
   tar xzf htslib-$SAMTOOLS_VERSION.tar.gz ; \
   tar xzf samtools-$SAMTOOLS_VERSION.tar.gz ; \
   rm -rf bcftools-$SAMTOOLS_VERSION.tar.gz ; \
   rm -rf htslib-$SAMTOOLS_VERSION.tar.gz ; \
   rm -rf samtools-$SAMTOOLS_VERSION.tar.gz ; \
   mv htslib-$SAMTOOLS_VERSION htslib ; \
   cd htslib; \
   make; \
   make install; \
   cd ..; \
   cd bcftools-$SAMTOOLS_VERSION ; \
   make -j HTSDIR=../htslib ; \
   make install ; \
   cd .. ; \
   cd samtools-$SAMTOOLS_VERSION ; \
   make -j HTSDIR=../htslib ; \
   make install ; \
   cd ../ ; \
   rm -rf htslib samtools-$SAMTOOLS_VERSION bcftools-$SAMTOOLS_VERSION

# Install Opal Python Client
RUN \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y apt-transport-https unzip

RUN \
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 379CE192D401AB61 && \
  echo 'deb https://dl.bintray.com/obiba/deb all main' | tee /etc/apt/sources.list.d/obiba.list && \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y opal-python-client

# Install Opal Server
RUN set -x && \
  cd /usr/share/ && \
  wget -q -O opal.zip https://github.com/obiba/opal/releases/download/${OPAL_VERSION}/opal-server-${OPAL_VERSION}-dist.zip && \
  unzip -q opal.zip && \
  rm opal.zip && \
  mv opal-server-${OPAL_VERSION} opal

# Install Search ES plugin
RUN \
  curl -L -o opal-search-es-${SEARCH_ES_VERSION}-dist.zip https://github.com/obiba/opal-search-es/releases/download/${SEARCH_ES_VERSION}/opal-search-es-${SEARCH_ES_VERSION}-dist.zip && \
  unzip opal-search-es-${SEARCH_ES_VERSION}-dist.zip -d $OPAL_HOME/plugins/ && \
  rm -f opal-search-es-${SEARCH_ES_VERSION}-dist.zip

# Install Jennite
RUN \
  curl -L -o jennite-vcf-store-${VCF_STORE_VERSION}-dist.zip https://github.com/obiba/jennite/releases/download/${VCF_STORE_VERSION}/jennite-vcf-store-${VCF_STORE_VERSION}-dist.zip && \
  unzip jennite-vcf-store-${VCF_STORE_VERSION}-dist.zip -d $OPAL_HOME/plugins/ && \
  rm -f jennite-vcf-store-${VCF_STORE_VERSION}-dist.zip

RUN chmod +x /usr/share/opal/bin/opal

COPY bin /opt/opal/bin
COPY data /opt/opal/data

RUN chmod +x -R /opt/opal/bin
RUN adduser --system --home $OPAL_HOME --no-create-home --disabled-password opal
RUN chown -R opal /opt/opal

VOLUME /srv

# https and http
EXPOSE 8443 8080

# Define default command.
COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["app"]
