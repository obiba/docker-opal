FROM obiba/opal:latest
RUN chmod +x /usr/share/opal/bin/opal

COPY bin /opt/opal/bin
COPY data /opt/opal/data
COPY testdata /testdata

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
