NAME   := evicertia/mono
ARCH   := amd64
CID    := $$(git log -1 --pretty=%h)
TAG    := testing
BOPTS  ?=

build:
	@docker build ${BOPTS} --platform=linux/${ARCH} --build-arg "CID=${CID}" -t "${NAME}:${CID}" .
	@docker tag ${NAME}:${CID} ${NAME}:${TAG}

tag:
	@docker tag ${NAME}:${CID} ${NAME}:${TAG}

push:
	@docker push ${NAME}:${TAG}

login:
	@docker log -u ${DOCKER_USER} -p ${DOCKER_PASS}
