# VERSION defines the version for the docker containers.
# To build a specific set of containers with a version,
# you can use the VERSION as an arg of the docker build command (e.g make docker VERSION=0.0.2)

# REGISTRY defines the registry where we store our images.
# To push to a specific registry,
# you can use the REGISTRY as an arg of the docker build command (e.g make docker REGISTRY=my_registry.com/username)
# You may also change the default value if you are using a different registry as a defaultt
REGISTRY ?= {{{dockerhubOrganizationName}}}}

# PROJECT defines suffix for images built & stored to docker hub.
PROJECT ?= {{{{appKey}}}}

# Commands
deploy: docker-build docker-push

docker-build: guard-VERSION guard-ENV guard-USER_ID guard-GROUP_ID guard-TARGET
	docker build \
		--file Dockerfile.${ENV} \
		--target ${TARGET} \
		--tag ${REGISTRY}/${PROJECT}-${TARGET}:${VERSION} \
		--build-arg UID=${USER_ID} \
		--build-arg GID=${GROUP_ID} \
		. && \
	echo "${TARGET} built."

each: guard-SCRIPT
	TARGET=cli make ${SCRIPT} && \
	TARGET=fpm make ${SCRIPT} && \
	TARGET=web make ${SCRIPT} && \
	TARGET=cron make ${SCRIPT}

build: guard-VERSION
	SCRIPT=docker-build make each
 
docker-push: guard-VERSION guard-TARGET
	docker push ${REGISTRY}/${PROJECT}-${TARGET}:${VERSION}

push: guard-VERSION
	SCRIPT=docker-push make each

guard-%:
	@ if [ "${${*}}" = "" ]; then \
		echo "$* is missing"; \
    	exit 1; \
	fi