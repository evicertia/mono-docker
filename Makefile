NAME   := evicertia/mono-service
PLAT   := linux/amd64,linux/arm64
CID    := $$(git log -1 --pretty=%h)
TAG    := testing

BUILDER		?= --builder cloud-evicertia-mono-builder
BOPTS		?=
VERSION		= $$(docker run --rm "evicertia/mono:$(TAG)" rpm -q mono-core --queryformat "%{version}-%{release}")

build:
	@docker pull --platform=${PLAT} "evicertia/mono:$(TAG)"
	@docker buildx build ${BOPTS} ${BUILDER} \
		--platform=${PLAT} \
		--build-arg "CID=${CID}" \
		--build-arg "VERSION=${VERSION}" \
		-t "${NAME}:${CID}" \
		-t "${NAME}:${TAG}" \
		--load .

push:
	@docker pull "evicertia/mono:$(TAG)"
	@docker buildx build ${BOPTS} ${BUILDER} \
		--platform=${PLAT} \
		--build-arg "CID=${CID}" \
		--build-arg "VERSION=${VERSION}" \
		-t "${NAME}:${CID}" \
		-t "${NAME}:${TAG}" \
		--push .

login:
	@docker log -u ${DOCKER_USER} -p ${DOCKER_PASS}
