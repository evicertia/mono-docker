NAME   := evicertia/mono
PLAT   := linux/amd64,linux/arm64
CID    := $$(git log -1 --pretty=%h)
TAG    := testing

BUILDER ?= --builder cloud-evicertia-mono-builder
BOPTS   ?=

build:
	@docker buildx build ${BOPTS} ${BUILDER} \
		--platform=${PLAT} \
		--build-arg "CID=${CID}" \
		-t "${NAME}:${CID}" \
		--load .

push:
	@docker buildx build ${BOPTS} ${BUILDER} \
		--platform=${PLAT} \
		--build-arg "CID=${CID}" \
		-t "${NAME}:${CID}" \
		-t "${NAME}:${TAG}" \
		--push .

login:
	@docker log -u ${DOCKER_USER} -p ${DOCKER_PASS}
