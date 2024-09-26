#
# Docker helper
#

no_cache=false

all:
	docker build --no-cache=true -t="obiba/opal:$(tag)" . && \
		docker build -t="obiba/opal:latest" . && \
		docker image push obiba/opal:$(tag) && \
		docker image push obiba/opal:latest

# Build Docker image
build:
	docker build --pull --no-cache=$(no_cache) --progress=plain -t="obiba/opal:$(tag)" .

push:
	docker image push obiba/opal:$(tag)

