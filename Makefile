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
	sudo docker build --no-cache=$(no_cache) -t="obiba/opal:snapshot" .

# Run a Opal Docker instance
run:
	sudo docker run -d -p 8843:8443 -p 8880:8080 --name opal --link mongodb:mongodb obiba/opal:snapshot

# Run a Opal Docker instance with shell
run-sh:
	sudo docker run -ti -p 8843:8443 -p 8880:8080 --name opal --link mongodb:mongodb obiba/opal:snapshot bash

# Show logs
logs:
	sudo docker logs opal

# Stop a Opal Docker instance
stop:
	sudo docker stop opal

# Stop and remove a Opal Docker instance
clean: stop
	sudo docker rm opal

#
# MongoDB
#

# Run a Mongodb Docker instance
run-mongodb:
	sudo docker run -d --name mongodb dockerfile/mongodb

# Stop a Mongodb Docker instance
stop-mongodb:
	sudo docker stop mongodb

# Stop and remove a Mongodb Docker instance
clean-mongodb: stop-mongodb
	sudo docker rm mongodb