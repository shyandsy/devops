CONTAINER_NAME=redis-8.2
REDIS_IMAGE=redis:8.2

REDIS_PORT ?= 6379
REDIS_PASSWORD ?= 

# host directory
HOST_DATA_DIR=/opt/redis/data
HOST_LOG_DIR=/opt/redis/logs
HOST_CONF_DIR=/opt/redis/conf

VOLUMES= \
	-v $(HOST_DATA_DIR):/data \
	-v $(HOST_LOG_DIR):/logs \
	-v $(HOST_CONF_DIR):/usr/local/etc/redis

.ONESHELL:
SHELL := /bin/bash

.PHONY: up down logs shell rm-volumes

# start container
up:
	@echo "=== Starting Redis container ==="

	@# get redis user REDIS_UID/REDIS_GID
	REDIS_UID=$$(docker run --rm $(REDIS_IMAGE) id -u redis)
	REDIS_GID=$$(docker run --rm $(REDIS_IMAGE) id -g redis)

	# create host directory and modify permission
	mkdir -p $(HOST_DATA_DIR) $(HOST_LOG_DIR) $(HOST_CONF_DIR)
	sudo chown -R $$REDIS_UID:$$REDIS_GID $(HOST_DATA_DIR) $(HOST_LOG_DIR)

	# init config file
	if [ ! -f $(HOST_CONF_DIR)/redis.conf ]; then
		docker run --rm $(REDIS_IMAGE) cat /usr/local/etc/redis/redis.conf > $(HOST_CONF_DIR)/redis.conf
		echo "Redis config initialized."
	fi

	# check old container
	@EXIST_CONTAINER=$$(docker ps -a -q -f name=$(CONTAINER_NAME))
	if [ -n "$$EXIST_CONTAINER" ]; then
		read -p "Container '$(CONTAINER_NAME)' exists. Delete it? (y/N) " yn
		case $$yn in
			[Yy]*)
				docker stop $(CONTAINER_NAME) >/dev/null 2>&1
				docker rm $(CONTAINER_NAME) >/dev/null 2>&1
				echo "Old container deleted."
				;;
			*)
				echo "Aborted."
				exit 1
				;;
		esac
	fi

	# generate startup command parameters
	ENV_PASSWORD=""
	if [ -n "$(REDIS_PASSWORD)" ]; then
		ENV_PASSWORD="--requirepass $(REDIS_PASSWORD)"
	fi

	# start Redis container
	CONTAINER_ID=$$(docker run -d --name $(CONTAINER_NAME) -p $(REDIS_PORT):6379 $(VOLUMES) $(REDIS_IMAGE) \
		redis-server /usr/local/etc/redis/redis.conf $$ENV_PASSWORD)
	echo "Redis container started with ID $$CONTAINER_ID on port $(REDIS_PORT)"

# stop and delete container
down:
	echo "Stopping and removing container '$(CONTAINER_NAME)'..."
	-docker stop $(CONTAINER_NAME) >/dev/null 2>&1 || true
	-docker rm $(CONTAINER_NAME) >/dev/null 2>&1 || true
	echo "Container '$(CONTAINER_NAME)' stopped and removed."

# show logs
logs:
	echo "Attaching logs for container '$(CONTAINER_NAME)'..."
	docker logs -f $(CONTAINER_NAME)

# enter container shell
shell:
	echo "Entering shell of container '$(CONTAINER_NAME)'..."
	docker exec -it $(CONTAINER_NAME) bash

# delete host directory (data and logs) (danger: will clear data)
rm-volumes:
	read -p "Are you sure to remove data, logs and config directories? (y/N) " yn
	case $$yn in
		[Yy]*)
			sudo rm -rf $(HOST_DATA_DIR) $(HOST_LOG_DIR) $(HOST_CONF_DIR)
			echo "Data, logs, and config directories removed."
			;;
		*)
			echo "Aborted."
			;;
	esac