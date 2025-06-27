#
# Docker helper
#

tag=snapshot
no_cache=true

# Build Docker image
build:
	docker build --pull --no-cache=$(no_cache) --progress=plain -t="obiba/opal:$(tag)" -f Dockerfile ..

push:
	docker image push obiba/opal:$(tag)

tag:
	docker image tag obiba/opal:$(tag) obiba/opal:$(tag2)

