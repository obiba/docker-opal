#
# Docker helper
#

no_cache=false

all:
	sudo docker build --no-cache=true -t="obiba/opal:$(tag)" . && \
		sudo docker build -t="obiba/opal:latest" . && \
		sudo docker image push obiba/opal:$(tag) && \
		sudo docker image push obiba/opal:latest

# Build Docker image
build:
	sudo docker build --no-cache=$(no_cache) --progress=plain -t="obiba/opal:$(tag)" .

push:
	sudo docker image push obiba/opal:$(tag)

