#
# Opal Dockerfile
#
# https://github.com/obiba/docker-opal
#

FROM obiba/docker-gosu:latest AS gosu


FROM openjdk:8-jdk-stretch AS server

ENV OPAL_ADMINISTRATOR_PASSWORD password
ENV OPAL_HOME /srv
ENV OPAL_DIST /usr/share/opal
ENV JAVA_OPTS "-Xms1G -Xmx2G -XX:MaxPermSize=256M -XX:+UseG1GC"

ENV OPAL_VERSION=2.16.0
ENV SEARCH_ES_VERSION=1.0.0
ENV VCF_STORE_VERSION=1.0.2
ENV SAMTOOLS_VERSION=1.4
ENV LIMESURVEY_PLUGIN_VERSION=1.1.0
ENV REDCAP_PLUGIN_VERSION=1.1.1
ENV SPSS_PLUGIN_VERSION=1.1.1
ENV READR_PLUGIN_VERSION=1.1.0
ENV READXL_PLUGIN_VERSION=1.1.0
ENV GOOGLESHEETS_PLUGIN_VERSION=1.0.0
ENV VALIDATE_PLUGIN_VERSION=1.0.1
ENV SAMTOOLS_VERSION 1.4
ENV HTSDIR /projects/htslib
ENV SAMDIR /projects/samtools-$SAMTOOLS_VERSION
ENV BCFDIR /projects/bcftools-$SAMTOOLS_VERSION

WORKDIR /tmp
RUN apt-get update && \
    apt-get install -y --no-install-recommends daemon psmisc

COPY --from=gosu /usr/local/bin/gosu /usr/local/bin/

# Install Opal Python Client
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y apt-transport-https unzip

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
    make gcc liblzma-dev libbz2-dev libncurses5-dev zlib1g-dev

# Install Search ES plugin
# Install Jennite
# Install Limesurvey datasource plugin
# Install REDCap datasource plugin
# Install SPSS datasource plugin
# Install ReadR datasource plugin
# Install ReadXL datasource plugin
# Install GoogleSheets datasource plugin
# Install Validate analysis plugin
RUN \
  mkdir $OPAL_DIST/plugins && \
  curl -L -o $OPAL_DIST/plugins/opal-search-es-${SEARCH_ES_VERSION}-dist.zip https://github.com/obiba/opal-search-es/releases/download/${SEARCH_ES_VERSION}/opal-search-es-${SEARCH_ES_VERSION}-dist.zip && \
  curl -L -o $OPAL_DIST/plugins/jennite-vcf-store-${VCF_STORE_VERSION}-dist.zip https://github.com/obiba/jennite/releases/download/${VCF_STORE_VERSION}/jennite-vcf-store-${VCF_STORE_VERSION}-dist.zip && \
  curl -L -o $OPAL_DIST/plugins/opal-datasource-limesurvey-${LIMESURVEY_PLUGIN_VERSION}-dist.zip https://github.com/obiba/opal-datasource-limesurvey/releases/download/${LIMESURVEY_PLUGIN_VERSION}/opal-datasource-limesurvey-${LIMESURVEY_PLUGIN_VERSION}-dist.zip && \
  curl -L -o $OPAL_DIST/plugins/opal-datasource-redcap-${REDCAP_PLUGIN_VERSION}-dist.zip https://github.com/obiba/opal-datasource-redcap/releases/download/${REDCAP_PLUGIN_VERSION}/opal-datasource-redcap-${REDCAP_PLUGIN_VERSION}-dist.zip && \
  curl -L -o $OPAL_DIST/plugins/opal-datasource-spss-${SPSS_PLUGIN_VERSION}-dist.zip https://github.com/obiba/opal-datasource-spss/releases/download/${SPSS_PLUGIN_VERSION}/opal-datasource-spss-${SPSS_PLUGIN_VERSION}-dist.zip && \
  curl -L -o $OPAL_DIST/plugins/opal-datasource-readr-${READR_PLUGIN_VERSION}-dist.zip https://github.com/obiba/opal-datasource-readr/releases/download/${READR_PLUGIN_VERSION}/opal-datasource-readr-${READR_PLUGIN_VERSION}-dist.zip && \
  curl -L -o $OPAL_DIST/plugins/opal-datasource-readxl-${READXL_PLUGIN_VERSION}-dist.zip https://github.com/obiba/opal-datasource-readxl/releases/download/${READXL_PLUGIN_VERSION}/opal-datasource-readxl-${READXL_PLUGIN_VERSION}-dist.zip && \
  curl -L -o $OPAL_DIST/plugins/opal-datasource-googlesheets4-${GOOGLESHEETS_PLUGIN_VERSION}-dist.zip https://github.com/obiba/opal-datasource-googlesheets4/releases/download/${GOOGLESHEETS_PLUGIN_VERSION}/opal-datasource-googlesheets4-${GOOGLESHEETS_PLUGIN_VERSION}-dist.zip && \
  curl -L -o $OPAL_DIST/plugins/opal-analysis-validate-${VALIDATE_PLUGIN_VERSION}-dist.zip https://github.com/obiba/opal-analysis-validate/releases/download/${VALIDATE_PLUGIN_VERSION}/opal-analysis-validate-${VALIDATE_PLUGIN_VERSION}-dist.zip

COPY /bin /opt/opal/bin
COPY /data /opt/opal/data

RUN adduser --system --home $OPAL_HOME --no-create-home --disabled-password opal; \
    chmod +x -R /opt/opal/bin; \
    chown -R opal /opt/opal; \
    chmod +x $OPAL_DIST/bin/opal

WORKDIR $OPAL_HOME

VOLUME $OPAL_HOME
EXPOSE 8080 8443

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/bin/bash" ,"/docker-entrypoint.sh"]
CMD ["app"]
