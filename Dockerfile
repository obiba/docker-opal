#
# Opal Dockerfile
#
# https://github.com/obiba/docker-opal
#

FROM debian:stretch-slim AS gosu

# grab gosu for easy step-down from root
# see https://github.com/tianon/gosu/blob/master/INSTALL.md
ENV GOSU_VERSION 1.10
RUN set -ex; \
	\
	fetchDeps=' \
		ca-certificates \
    gnupg2 \
    dirmngr \
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
	gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
	gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
	rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc; \
	\
	chmod +x /usr/local/bin/gosu; \
  # verify that the binary works
	gosu nobody true; \
	\
	apt-get purge -y --auto-remove $fetchDeps


FROM maven:3.5.4-slim AS building

ENV OPAL_BRANCH master

SHELL ["/bin/bash", "-c"]

RUN apt-get update && \
    apt-get install -y --no-install-recommends devscripts debhelper build-essential fakeroot git

WORKDIR /projects
RUN git clone https://github.com/obiba/opal.git

WORKDIR /projects/opal

RUN git checkout $OPAL_BRANCH; \
    mvn clean install && \
    mvn -Prelease org.apache.maven.plugins:maven-antrun-plugin:run@make-deb


FROM openjdk:8-jdk-stretch AS server

ENV OPAL_ADMINISTRATOR_PASSWORD password
ENV OPAL_HOME /srv
ENV JAVA_OPTS "-Xms1G -Xmx2G -XX:MaxPermSize=256M -XX:+UseG1GC"

ENV SAMTOOLS_VERSION 1.4
ENV HTSDIR /projects/htslib
ENV SAMDIR /projects/samtools-$SAMTOOLS_VERSION
ENV BCFDIR /projects/bcftools-$SAMTOOLS_VERSION

WORKDIR /tmp
COPY --from=building /projects/opal/opal-server/target/opal_*.deb .
RUN apt-get update && \
    apt-get install -y --no-install-recommends daemon psmisc && \
    DEBIAN_FRONTEND=noninteractive dpkg -i opal_*.deb

COPY --from=gosu /usr/local/bin/gosu /usr/local/bin/

COPY /bin /opt/opal/bin
RUN chmod +x -R /opt/opal/bin; \
    chown -R opal /opt/opal; \
    chmod +x /usr/share/opal/bin/opal

# Plugins dependencies
WORKDIR /projects
RUN apt-get update; \
    apt-get install -y curl make gcc liblzma-dev libbz2-dev libncurses5-dev zlib1g-dev; \
    curl -L https://github.com/samtools/htslib/archive/$SAMTOOLS_VERSION.tar.gz | tar xz; \
    curl -L https://github.com/samtools/samtools/archive/$SAMTOOLS_VERSION.tar.gz | tar xz; \
    curl -L https://github.com/samtools/bcftools/archive/$SAMTOOLS_VERSION.tar.gz | tar xz;

RUN mv $HTSDIR-$SAMTOOLS_VERSION $HTSDIR
WORKDIR $HTSDIR
RUN make; \
    make install;

WORKDIR $SAMDIR
RUN make -j HTSDIR=$HTSDIR ; \
    make install;

WORKDIR $BCFDIR
RUN make -j HTSDIR=$HTSDIR ; \
    make install;

RUN apt-get purge -y \
    curl curl make gcc liblzma-dev libbz2-dev libncurses5-dev zlib1g-dev

VOLUME $OPAL_HOME
EXPOSE 8080 8443

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/bin/bash" ,"/docker-entrypoint.sh"]
CMD ["app"]
