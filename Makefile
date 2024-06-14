#
# Docker helper
#

docker_compose_file=docker-compose.yml

up:
	docker compose -f $(docker_compose_file) up -d --remove-orphans

down:
	docker compose -f $(docker_compose_file) down

stop:
	docker compose -f $(docker_compose_file) stop

start:
	docker compose -f $(docker_compose_file) start

restart:
	docker compose -f $(docker_compose_file) restart

pull:
	docker compose -f $(docker_compose_file) pull --include-deps

logs:
	docker compose -f $(docker_compose_file) logs -f

build:
	docker compose -f $(docker_compose_file) build --no-cache

# Build Docker image
build-image:
	sudo docker build --no-cache=true -t="obiba/opal:snapshot" .

push-image:
	sudo docker image push obiba/opal:snapshot
clean:
	rm -rf target
