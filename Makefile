NAME   := evicertia/mono-service
PLAT   := linux/amd64,linux/arm64
CID    := $$(git log -1 --pretty=%h)
TAG    := testing
BOPTS  ?=

VERSION		= $$(docker run --rm "evicertia/mono:$(TAG)" rpm -q mono-core --queryformat "%{version}-%{release}")
BUILD_EXTRA ?=

build:
	@docker pull "evicertia/mono:$(TAG)"
	@docker buildx build ${BOPTS} \
		--platform=${PLAT} \
		--build-arg "CID=${CID}" \
		--build-arg "VERSION=${VERSION}" \
		${BUILD_EXTRA} \
		-t "${NAME}:${CID}" .
	@docker tag "${NAME}:${CID}" "${NAME}:${TAG}"

tag: build
	@docker tag "${NAME}:${CID}" "${NAME}:${TAG}"

push: tag
	@docker push ${NAME}:${TAG}

login:
	@docker log -u ${DOCKER_USER} -p ${DOCKER_PASS}
