ARG MONO_DOCKER_TAG=testing

FROM --platform=$BUILDPLATFORM evicertia/mono:${MONO_DOCKER_TAG}

ARG VERSION=unknown
ARG TARGETARCH
ARG COMMIT=0

LABEL version="${VERSION}.${COMMIT}"
LABEL description="AlmaLinux based mono image for running services"
LABEL maintainer="pablo@evicertia.com"
LABEL vendor="evicertia"

WORKDIR /

ENV DOCKERIZE_VERSION=v0.9.2

RUN microdnf -y install dnf && \
    dnf --allowerasing -y install \
    libcurl-full \
    libcurl-devel \
    curl-full \
    xmlstarlet
RUN dnf clean all && dnf remove -y --setopt=protected_packages='' dnf python3-dnf
RUN microdnf clean all && rm -rf /var/cache/yum/* && rm -rf /var/cache/dnf/*

RUN curl -LO https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-${TARGETARCH}-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-${TARGETARCH}-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-${TARGETARCH}-$DOCKERIZE_VERSION.tar.gz

VOLUME /conf
VOLUME /data
VOLUME /logs

COPY ./files/main.inc /
