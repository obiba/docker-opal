Docker Opal
===========

Use [docker compose](https://docs.docker.com/compose/) to launch opal, rock and mongodb/mysql/mariadb/postgres applications:

```
docker-compose up
```

Then connect to:

[http://localhost:8880](http://localhost:8880)

Standalone setup
----------------

`docker-compose.h2.yml` is the smallest stack: Opal, Rock and the Grafana stack of the
[OpenTelemetry](#opentelemetry) section, and no database server at all. It is a stack of its own,
not an overlay:

```
docker compose -f docker-compose.h2.yml up
```

With no `MONGO_*`, `MYSQLDATA_*`, `MARIADBDATA_*` or `POSTGRESDATA_*` variable set, Opal starts
with its configuration in the embedded H2 database (see below), the first-run setup registers no
data database, and the projects have nowhere to store their tables until one is registered under
**Administration > Databases**. That is enough to log in, run DataSHIELD on resources with Rock,
or try the OpenTelemetry export at [http://localhost:3000](http://localhost:3000), without a MongoDB
or an SQL server to run.

Opal's home and Rock's home are on named volumes, `opal-home-h2` and `rock-home-h2`, so the
configuration survives a `docker compose down` and

```
docker compose -f docker-compose.h2.yml down -v
```

starts over. The network and the volumes are named apart from the default stack's (`opal-h2` rather
than `opal`), so switching from one stack to the other does not mix their homes; both publish
ports 8880 and 3000 though, so bring one down before starting the other.

All-PostgreSQL setup
--------------------

`docker-compose.postgres.yml` puts everything on one database engine: a `postgresconfig` server
for Opal's configuration (see [Configuration database](#configuration-database) below), a
`postgresdata` server for the data, and no MongoDB, MySQL or MariaDB. Like the standalone one it
is a stack of its own rather than an overlay:

```
docker compose -f docker-compose.postgres.yml up
```

The `POSTGRESCONFIG_*` variables are in the compose file from the start, which is what the
configuration database needs: they cannot be added to an Opal that has already started once.

Everything in it, Opal's home, the two PostgreSQL servers and Rock's home, is on a named volume
(`opal-home-pg`, `opal-config-pg`, `opal-data-pg`, `rock-home-pg`), so a `docker compose down`
keeps the configuration and the data together and

```
docker compose -f docker-compose.postgres.yml down -v
```

removes them together, which matters here more than elsewhere: the secret key in Opal's home and
the configuration in `postgresconfig` are only good as a pair. The network is `opal-postgres`, apart
from the other stacks', and it publishes the same ports 8880 and 3000.

Configuration database
----------------------

Since Opal 6.0.0, Opal keeps its own configuration (projects, permissions, users, registered
databases, DataSHIELD profiles...) in an embedded H2 database under `$OPAL_HOME/data/config`. To
keep it on a PostgreSQL server instead, set `POSTGRESCONFIG_HOST`:

```
docker run -e POSTGRESCONFIG_HOST=postgres -e POSTGRESCONFIG_PASSWORD=secret obiba/opal
```

| Variable | |
| --- | --- |
| `POSTGRESCONFIG_HOST` | the PostgreSQL server. Setting it is what switches the configuration database over |
| `POSTGRESCONFIG_PORT` | defaults to `5432` |
| `POSTGRESCONFIG_DATABASE` | an existing, empty database, `opal_config` by default. Opal creates the schema itself |
| `POSTGRESCONFIG_USER` | defaults to `opal` |
| `POSTGRESCONFIG_PASSWORD` | required: the embedded database uses a password Opal generates, an external one uses the server's |

These are written to `config.datasource.*` and `config.hibernate.dialect` in
`conf/opal-config.properties` at every start, and Opal waits for the port to answer before
starting, so a database container started at the same time is fine.

Two things to know:

- **Set it before the first start.** Opal writes its configuration to whatever database is
  configured at that moment, and pointing an Opal that already has a configuration at an empty
  PostgreSQL gives an Opal with an empty configuration: no administrator password set, no
  databases registered, no projects. The `.set_password.done` and `.first_run.done` markers in
  `OPAL_HOME` are not reset, so the first-run setup does not run again either.
- **Back it up together with `OPAL_HOME`.** With the embedded database, `data/config` and
  `data/opal-config.xml` travel together in the volume. On PostgreSQL the configuration is in the
  server, and the secret key that salts its user passwords and encrypts its stored credentials is still in
  `data/opal-config.xml`: a restore needs both from the same moment.

The other databases (`MONGO_*`, `MYSQLDATA_*`, `MARIADBDATA_*`, `POSTGRESDATA_*`, and the `*IDS_*`
ones) are unchanged: they hold the data and the identifiers, and are registered in the
configuration through Opal's REST API on the first run.

OpenTelemetry
-------------

Since Opal 6.0.0, Opal exports its logs, DataSHIELD traces and DataSHIELD metrics over OTLP. One
variable turns on all three; with none set, no SDK is built, nothing is exported and nothing is
printed:

```
docker run -e OTEL_EXPORTER_OTLP_ENDPOINT=https://collector.example.org:4318 obiba/opal
```

Opal ships the OTLP/HTTP sender only, so this is the http/protobuf endpoint - port 4318 on a
standard collector, not the 4317 gRPC port. Opal prints `OpenTelemetry export enabled.` at startup
when it picks the endpoint up. A signal-specific endpoint (`OTEL_EXPORTER_OTLP_LOGS_ENDPOINT`,
`..._TRACES_ENDPOINT`, `..._METRICS_ENDPOINT`) on its own enables export too.

| Variable | |
| --- | --- |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | the collector, e.g. `https://collector:4318`. Setting it is what enables export |
| `OTEL_SERVICE_NAME` | name reported to the backend, defaults to `opal` |
| `OTEL_RESOURCE_ATTRIBUTES` | extra attributes, e.g. to tell nodes apart in a federated study |
| `OTEL_EXPORTER_OTLP_HEADERS` | e.g. `Authorization=Bearer%20...` if the collector wants a token |
| `OTEL_EXPORTER_OTLP_CERTIFICATE` | trusted CA, for a TLS endpoint |
| `OTEL_EXPORTER_OTLP_CLIENT_CERTIFICATE`, `..._CLIENT_KEY` | client cert and key, for mTLS |
| `OTEL_METRIC_EXPORT_INTERVAL` | metrics are exported every 60s by default |

The protocol, the service name and the three per-signal exporters are set by Opal as defaults only,
so the matching `OTEL_` variables still override them. Two are worth knowing about:

- `OTEL_EXPORTER_OTLP_PROTOCOL` - leave it alone. Opal ships the OTLP/HTTP sender only, so `grpc`
  fails to build the SDK. Opal logs `Failed to initialize OpenTelemetry, continuing without it`,
  starts, and exports nothing.
- `OTEL_LOGS_EXPORTER`, `OTEL_TRACES_EXPORTER`, `OTEL_METRICS_EXPORTER` - set one to `none` to drop
  that signal and keep the other two. `OTEL_SDK_DISABLED=true` turns everything off without having
  to unset the endpoint.

### What is exported

- **Logs**: `opal.log` and `rest.log` records, and the DataSHIELD audit trail on scope
  `datashield.user`, with the `ds_*` fields renamed to `datashield.session.id`, `datashield.action`,
  `datashield.script`, `enduser.id`, `client.address` and so on. The `datashield.log` file in the
  volume is unchanged: the renaming happens on the way to the collector only.
- **Traces**: one trace per DataSHIELD session, rooted on a `datashield.session` span that stays
  open for as long as the session does, with `datashield.open`, `.assign`, `.parse`, `.aggregate`,
  `.ws_save`, `.ws_restore` and `.close` underneath. Operations are exported as they end, so the
  trace is readable while the session is still open. A script the restriction refuses is a
  `datashield.parse` span with status `ERROR` and the submitted expression on it. Each audit record
  carries its session's `trace_id`, so a backend like Grafana goes from a span to its log lines and
  back.
- **Metrics**, on scope `org.obiba.opal.datashield`: `datashield.operation.count` and
  `datashield.operation.duration` (seconds, by action, profile and outcome),
  `datashield.session.active` (by profile, read from the session manager on collection) and
  `datashield.quota.rejection` (by quota metric).

### Upgrading a volume from before 6.0.0

`conf/` is copied from the image into `OPAL_HOME` on the first run only, and never touched again.
An `OPAL_HOME` volume created by an older image therefore keeps a `logback.xml` with no OpenTelemetry
appenders in it: set an endpoint on such a container and it exports its traces and its metrics and
not one log record. Opal says so at startup:

```
OpenTelemetry export enabled.
WARNING: conf/logback.xml declares no OpenTelemetry appender, so no log record will be exported ...
```

If you never edited that file, replace it with the one from the image:

```
docker compose cp opal:/usr/share/opal/conf/logback.xml /tmp/test-opal/conf/logback.xml
```

Otherwise merge the `otel`, `otelrest`, `otelraw` and `otelds` appenders, and the `appender-ref`
entries that use them, from the image's file into yours.

### Trying it locally

`docker-compose.yml` already points Opal at an `lgtm` service - the `grafana/otel-lgtm` image, an
OpenTelemetry collector feeding Loki (logs), Tempo (traces) and Prometheus (metrics), with Grafana
over all three. `docker compose up`, then open
[http://localhost:3000](http://localhost:3000) (admin / admin), open a DataSHIELD session, assign a
table, run an aggregation and close it:

| | |
| --- | --- |
| Logs | Explore > Loki, `{service_name="opal"}`, or `{service_name="opal", scope_name="datashield.user"}` for the audit trail alone |
| Traces | Explore > Tempo, Search, service `opal`, span `datashield.aggregate` |
| Metrics | Explore > Prometheus, `datashield_operation_count_total`, `datashield_operation_duration_seconds_bucket`, `datashield_session_active`, `datashield_quota_rejection_total` |

Nothing is persisted: the whole stack is in the container and goes when it does.

To trace the HTTP requests, JDBC and R server calls around the DataSHIELD operations as well, mount
the OpenTelemetry Java agent and pass it with `-e JAVA_OPTS="-Xms1G -Xmx2G -javaagent:/opt/opentelemetry-javaagent.jar"`.
Opal needs no change: the DataSHIELD session traces stay traces of their own, linked to the HTTP
request spans that asked for each operation.

### Securing the stream

The DataSHIELD stream carries the submitted R expressions, the usernames and the client addresses -
it is the security audit trail, and unlike `datashield.log` it leaves the host. Point it at a
collector inside your trust boundary, over `https://`, and pass any token with `-e` or an env file
at run time rather than baking it into an image or a compose file that is committed.

### Traces in MLflow

[MLflow](https://mlflow.org) Server (3.6+) accepts OpenTelemetry traces over OTLP/HTTP, and
`docker-compose.mlflow.yml` is an overlay that sends Opal's traces there instead of Tempo:

```
docker compose -f docker-compose.yml -f docker-compose.mlflow.yml up
```

Then open [http://localhost:5000](http://localhost:5000), run a DataSHIELD session, and look under
**Experiments > Default > Traces**. One session is one trace, rooted in a `datashield.session` span
with the `datashield.parse`, `datashield.aggregate`, `datashield.assign` and `datashield.close`
spans under it, each carrying the `datashield.action`, `datashield.profile`, `datashield.session.id`
and `datashield.script` attributes of the audit log. The root span is only exported when the session
ends, so the trace shows as **In progress** until the session is closed, then completes with the
session's full duration.

MLflow only takes traces, so the audit logs and the metrics still go to Grafana: the overlay adds the
signal-specific variables and leaves `OTEL_EXPORTER_OTLP_ENDPOINT` in place for the other two.

```
OTEL_EXPORTER_OTLP_TRACES_ENDPOINT=http://mlflow:5000/v1/traces
OTEL_EXPORTER_OTLP_TRACES_HEADERS=x-mlflow-experiment-id=0
```

Experiment `0` is the `Default` one that every MLflow has. To file the traces elsewhere, create an
experiment in the UI and put its id in the header. The MLflow store is a SQLite file inside the
container, gone with it like the rest of the stack.