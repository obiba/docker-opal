#
# Docker helper
#

no_cache=false

help:
	@echo "make build run-mongodb run stop clean"

#
# Opal
#

# Build Opal Docker image
build:
	docker build --no-cache=$(no_cache) -t="obiba/opal:snapshot" .

# Run a Opal Docker instance
run:
	docker run -d -p 8843:8443 -p 8880:8080 --name opal --link mongodb:mongodb obiba/opal:snapshot

# Run a Opal Docker instance with shell
run-sh:
	docker run -ti -p 8843:8443 -p 8880:8080 --name opal --link mongodb:mongodb obiba/opal:snapshot bash

# Show logs
logs:
	docker logs opal

# Stop a Opal Docker instance
stop:
	docker stop opal

# Stop and remove a Opal Docker instance
clean: stop
	docker rm opal

#
# MongoDB
#

# Run a Mongodb Docker instance
run-mongodb:
	docker run -d --name mongodb dockerfile/mongodb

# Stop a Mongodb Docker instance
stop-mongodb:
	docker stop mongodb

# Stop and remove a Mongodb Docker instance
clean-mongodb: stop-mongodb
	docker rm mongodb