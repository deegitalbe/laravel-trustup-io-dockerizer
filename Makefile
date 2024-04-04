# VERSION defines the version for the docker containers.
# To build a specific set of containers with a version,
# you can use the VERSION as an arg of the docker build command (e.g make docker VERSION=0.0.2)

# REGISTRY defines the registry where we store our images.
# To push to a specific registry,
# you can use the REGISTRY as an arg of the docker build command (e.g make docker REGISTRY=my_registry.com/username)
# You may also change the default value if you are using a different registry as a defaultt
REGISTRY ?= henrotaym

# PROJECT defines suffix for images built & stored to docker hub.
PROJECT ?= laravel-trustup-io-deployment

# Commands
deploy: build push

build-image: guard-VERSION guard-TARGET guard-USER_ID guard-GROUP_ID
	docker build -f Dockerfile \
		--target ${TARGET} \
		--tag ${REGISTRY}/${PROJECT}-${TARGET}:${VERSION} \
		--build-arg UID=${USER_ID} \
		--build-arg GID=${GROUP_ID} \
		. &&\
	echo "${TARGET} built"

build-runner: 
	TARGET=runner make build-image

build-cli: 
	TARGET=cli make build-image

build: guard-VERSION
	make build-cli && \
	make build-runner && \
	echo "Images were successfully built."

push-image: guard-VERSION guard-TARGET
	docker push ${REGISTRY}/${PROJECT}-${TARGET}:${VERSION}
 
push: guard-VERSION
	TARGET=cli make push-image && \
	TARGET=runner make push-image && \
	echo "Images were successfully pushed."

guard-%:
	@ if [ "${${*}}" = "" ]; then \
		echo "$* is missing"; \
    	exit 1; \
	fi