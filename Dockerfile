ARG OS_VERSION=7
ARG MONO_DOCKER_TAG=6.12
FROM evicertia/mono:${MONO_DOCKER_TAG}-el${OS_VERSION}

ARG COMMIT=0

LABEL version="${MONO_DOCKER_TAG}.${COMMIT}"
LABEL description="CentOS/Alma-${OS_VERSION} based mono image for running services"
LABEL maintainer="pablo@evicertia.com"
LABEL vendor="evicertia"

WORKDIR /

ENV DOCKERIZE_VERSION v0.6.1

RUN sed -i -e '/^mirrorlist/d;/^#baseurl=/{s,^#,,;s,/mirror,/vault,;}' /etc/yum.repos.d/CentOS*.repo

RUN yum -y install mono-basic \
    libcurl \
    libcurl-devel \
    curl \
    xmlstarlet

RUN curl -LO https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

VOLUME /conf
VOLUME /data
VOLUME /logs

COPY ./files/main.inc /
