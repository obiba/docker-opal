Docker Opal
===========

Use [docker compose](https://docs.docker.com/compose/) to launch opal, rock and mongodb/mysql/mariadb/postgres applications:

```
docker-compose up
```

Then connect to:

[http://localhost:8880](http://localhost:8880)

Local development
-----------------

This branch builds the image from a locally built Opal instead of a release. Build Opal first, then
build the image from the parent directory of `opal/` and `docker-opal/`:

```
cd opal && mvn -DskipTests install
cd ../docker-opal && make build
```

`OPAL_VERSION` in the `Dockerfile` has to match the directory under
`opal/opal-server/target/` — `6.0-SNAPSHOT` at the time of writing. `make build` tags the image
`obiba/opal:snapshot`, which is what `docker-compose.yml` runs.

### OpenTelemetry

`docker compose up` also starts a `grafana/otel-lgtm` container: an OpenTelemetry collector feeding
Loki, Tempo and Prometheus, with Grafana over all three. Opal is pointed at it by a single variable
already set on the `opal` service, which enables the DataSHIELD audit log export, the traces and the
metrics together:

```
OTEL_EXPORTER_OTLP_ENDPOINT=http://lgtm:4318
```

Open [http://localhost:3000](http://localhost:3000) (`admin` / `admin`), run a DataSHIELD session,
then look in **Explore**:

| | Datasource | Try |
| --- | --- | --- |
| Audit logs | Loki | `{service_name="opal", scope_name="datashield.user"}` |
| Traces | Tempo | Search, service `opal`, span name `datashield.aggregate` |
| Metrics | Prometheus | `datashield_operation_count_total`, `datashield_session_active` |

The log records carry `datashield_action`, `datashield_profile`, `datashield_session_id`,
`datashield_script`, `enduser_id` and `client_address` as labels. `$OPAL_HOME/logs/datashield.log`
is written exactly as before — the export is additive.

Nothing is persisted: the whole stack lives in the container and goes when it does. To turn the
export off, comment out the `OTEL_` variables on the `opal` service; with no endpoint set Opal builds
no SDK and sends nothing.
