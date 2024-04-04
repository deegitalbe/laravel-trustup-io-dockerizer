# VERSION defines the version for the docker containers.
# To build a specific set of containers with a version,
# you can use the VERSION as an arg of the docker build command (e.g make docker VERSION=0.0.2)

# REGISTRY defines the registry where we store our images.
# To push to a specific registry,
# you can use the REGISTRY as an arg of the docker build command (e.g make docker REGISTRY=my_registry.com/username)
# You may also change the default value if you are using a different registry as a defaultt
REGISTRY ?= {{{{dockerhubOrganizationName}}}}

# PROJECT defines suffix for images built & stored to docker hub.
PROJECT ?= {{{{appKey}}}}

# Commands
deploy: docker-build docker-push

docker-build-cli: guard-VERSION
	docker build -f Dockerfile.production . --target cli -t ${REGISTRY}/${PROJECT}-cli:${VERSION} \
	&& echo "cli built"

docker-build-cron: guard-VERSION
	docker build -f Dockerfile.production . --target cron -t ${REGISTRY}/${PROJECT}-cron:${VERSION} \
	&& echo "cron built"

docker-build-fpm: guard-VERSION
	docker build -f Dockerfile.production . --target fpm_server -t ${REGISTRY}/${PROJECT}-fpm:${VERSION} \
	&& echo "fpm built"

docker-build-web: guard-VERSION
	docker build -f Dockerfile.production . --target web_server -t ${REGISTRY}/${PROJECT}-web:${VERSION} \
	&& echo "web built"

docker-build: guard-VERSION
	docker build -f Dockerfile.production . --target cli -t ${REGISTRY}/${PROJECT}-cli:${VERSION} & \
	docker build -f Dockerfile.production . --target cron -t ${REGISTRY}/${PROJECT}-cron:${VERSION} & \
	docker build -f Dockerfile.production . --target fpm_server -t ${REGISTRY}/${PROJECT}-fpm:${VERSION} & \
	docker build -f Dockerfile.production . --target web_server -t ${REGISTRY}/${PROJECT}-web:${VERSION} & \
	wait
	echo "Images were successfully built."
 
docker-push: guard-VERSION
	docker push ${REGISTRY}/${PROJECT}-cli:${VERSION} & \
	docker push ${REGISTRY}/${PROJECT}-cron:${VERSION} & \
	docker push ${REGISTRY}/${PROJECT}-fpm:${VERSION} & \
	docker push ${REGISTRY}/${PROJECT}-web:${VERSION} & \
	wait
	echo "Images were successfully pushed."

guard-%:
	@ if [ "${${*}}" = "" ]; then \
		echo "$* is missing"; \
    	exit 1; \
	fi