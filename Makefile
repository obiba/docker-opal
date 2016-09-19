#
# Docker helper
#

no_cache=false

# Build Docker image
build:
	sudo docker build --no-cache=$(no_cache) -t="obiba/opal:snapshot" .

build25x:
	sudo docker build --no-cache=$(no_cache) -t="obiba/opal:2.5-snapshot" 2.5-snapshot 