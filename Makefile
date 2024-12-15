#
# Docker helper
#

no_cache=true

# Build Docker image
build:
	docker build --pull --no-cache=$(no_cache) --progress=plain -t="obiba/opal:$(tag)" .

push:
	docker image push obiba/opal:$(tag)

