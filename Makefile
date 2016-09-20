#
# Docker helper
#

no_cache=false

# Build Docker image
build:
	sudo docker build --no-cache=$(no_cache) -t="obiba/opal:snapshot" .

build-version:
	sudo docker build --no-cache=$(no_cache) -t="obiba/opal:$(version)" $(version) 

build-branch:
	sudo docker build --no-cache=$(no_cache) -t="obiba/opal:branch-snapshot" branch-snapshot 