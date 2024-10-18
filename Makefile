NAME   := evicertia/mono
ARCH   := amd64
CID    := $$(git log -1 --pretty=%h)
TAG    := testing
BOPTS  ?=

build:
	@docker build ${BOPTS} --platform=linux/${ARCH} -t "${NAME}:${CID}" .
	@docker tag ${NAME}:${CID} ${TAG}

push:
	@docker push ${NAME}

login:
	@docker log -u ${DOCKER_USER} -p ${DOCKER_PASS}
