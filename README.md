Docker Opal
===========

Use [docker compose](https://docs.docker.com/compose/) to launch opal, rock and mongodb/mysql/mariadb/postgres applications:

```
docker-compose up
```

Then connect to:

[http://localhost:8880](http://localhost:8880)

OpenTelemetry
-------------

Opal exports its audit logs, DataSHIELD traces and DataSHIELD metrics over OTLP. One variable turns
on all three; with none set, nothing is exported and nothing is allocated:

```
docker run -e OTEL_EXPORTER_OTLP_ENDPOINT=https://collector.example.org:4318 obiba/opal
```

Opal ships the OTLP/HTTP sender only, so this is the http/protobuf endpoint - port 4318 on a
standard collector, not the 4317 gRPC port. Opal prints `OpenTelemetry export enabled.` at startup
when it picks the endpoint up.

| Variable | |
| --- | --- |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | the collector, e.g. `https://collector:4318`. Setting it is what enables export |
| `OTEL_SERVICE_NAME` | name reported to the backend, defaults to `opal` |
| `OTEL_RESOURCE_ATTRIBUTES` | extra attributes, e.g. to tell nodes apart in a federated study |
| `OTEL_EXPORTER_OTLP_HEADERS` | e.g. `Authorization=Bearer%20...` if the collector wants a token |
| `OTEL_EXPORTER_OTLP_CERTIFICATE` | trusted CA, for a TLS endpoint |
| `OTEL_METRIC_EXPORT_INTERVAL` | metrics are exported every 60s by default |

To try it locally, uncomment the `OTEL_` variables on the `opal` service in `docker-compose.yml`, add
`otel-collector` to its `links`, and uncomment the `otel-collector` service. `docker compose logs
otel-collector` then prints every record, span and data point as it arrives.

The DataSHIELD stream carries the submitted R expressions, the usernames and the client addresses -
it is the security audit trail, and unlike `datashield.log` it leaves the host. Point it at a
collector inside your trust boundary, over `https://`, and keep any token out of the image.
