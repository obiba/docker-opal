help:
	@echo "make build run-mongodb run stop clean"

# List Docker images
images:
	sudo docker images

#
# Opal
#

# Build Opal Docker image
build:
	sudo docker build -t="obiba/opal:snapshot" .

# Run a Opal Docker instance
run:
	sudo docker run -d -p 8843:8443 --name opal --link mongodb:mongodb obiba/opal:snapshot

# Run a Opal Docker instance with database setup
run-setup:
	sudo docker run -d -p 8843:8443 --name opal --link mongodb:mongodb -v `pwd`/data:/data obiba/opal:snapshot bash start.sh

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