#
# Docker helper
#

no_cache=false

# Build Docker image
build:
	sudo docker build --no-cache=$(no_cache) -t="obiba/opal:$(tag)" .

push:
	sudo docker image push obiba/opal:$(tag)

