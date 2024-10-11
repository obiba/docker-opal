#
# Opal Dockerfile
#
# https://github.com/obiba/docker-opal
#

FROM tianon/gosu:latest AS gosu

FROM docker.io/library/eclipse-temurin:21-jre-jammy AS server-released

ENV OPAL_ADMINISTRATOR_PASSWORD password
ENV OPAL_HOME /srv
ENV OPAL_DIST /usr/share/opal
ENV JAVA_OPTS "-Xms1G -Xmx2G -XX:+UseG1GC"

ENV OPAL_VERSION=5.0.0
ENV LIMESURVEY_PLUGIN_VERSION=2.0.0
ENV REDCAP_PLUGIN_VERSION=2.0.0
ENV SPSS_PLUGIN_VERSION=2.0.0
ENV READR_PLUGIN_VERSION=2.0.0
ENV READXL_PLUGIN_VERSION=2.0.0
ENV GOOGLESHEETS_PLUGIN_VERSION=2.0.0
ENV VALIDATE_PLUGIN_VERSION=2.0.0

WORKDIR /tmp
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y daemon psmisc apt-transport-https unzip curl python3-pip libcurl4-openssl-dev libssl-dev && \
    apt-get clean &&  \
    rm -rf /var/lib/apt/lists/*

COPY --from=gosu /usr/local/bin/gosu /usr/local/bin/

# Install Opal Python Client
RUN pip install obiba-opal

# Install Opal Server
RUN set -x && \
  cd /usr/share/ && \
  wget -q -O opal.zip https://github.com/obiba/opal/releases/download/${OPAL_VERSION}/opal-server-${OPAL_VERSION}-dist.zip && \
  unzip -q opal.zip && \
  rm opal.zip && \
  mv opal-server-${OPAL_VERSION} opal

# Plugins dependencies
WORKDIR /projects

# Install Limesurvey datasource plugin
# Install REDCap datasource plugin
# Install SPSS datasource plugin
# Install ReadR datasource plugin
# Install ReadXL datasource plugin
# Install GoogleSheets datasource plugin
# Install Validate analysis plugin
RUN \
  mkdir $OPAL_DIST/plugins && \
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
