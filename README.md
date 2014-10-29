Docker Opal
===========

Default launch of a Opal container:

`sudo docker run -d -p 8843:8443 obiba/opal:snapshot`

To link with a MongoDB container, use the Makefile:

```
make run-mongodb
make run
```

Then connect to:

[https://localhost:8843](https://localhost:8843)
