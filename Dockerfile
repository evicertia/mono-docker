ARG OS_VERSION=9
ARG MONO_VERSION=6.12.0.182-18.2.nw.el${OS_VERSION}
ARG GTKSHARP_VERSION=2.12.45-10.1.nw.el${OS_VERSION}
ARG MSBUILD_VERSION=16.10.1+xamarinxplat.2021.05.26.14.00-8.1.nw.el${OS_VERSION}
ARG CID=0

FROM --platform=$BUILDPLATFORM almalinux:$OS_VERSION-minimal
ARG TARGETARCH
ARG OS_VERSION
ARG MONO_VERSION
ARG GTKSHARP_VERSION
ARG MSBUILD_VERSION
ARG CID

LABEL version=${MONO_VERSION}.${CID}
LABEL description="AlmaLinux-${OS_VERSION} based mono base image"
LABEL maintainer="pablo@evicertia.com"
LABEL vendor="evicertia"

WORKDIR /

# Install base stuff..

ADD files/evirpms.repo /etc/yum.repos.d/
ADD files/netway-mono-arm64.repo /etc/yum.repos.d/
#RUN sed -i -e '/^mirrorlist/d;/^#baseurl=/{s,^#,,;s,/mirror,/vault,;}' /etc/yum.repos.d/CentOS*.repo
RUN microdnf -y install openssl ca-certificates epel-release
RUN echo ${MONO_VERSION} > /MONO_VERSION
RUN microdnf -y --enablerepo=mono-${TARGETARCH} install \
    git dos2unix rpm-build parallel lsb-release procps \
    selinux-policy-\* checkpolicy \
    mono-core-${MONO_VERSION} \
    mono-web-${MONO_VERSION} \
    mono-data-${MONO_VERSION} \
    mono-data-sqlite-${MONO_VERSION} \
    mono-data-oracle-${MONO_VERSION} \
    mono-extras-${MONO_VERSION} \
    mono-wcf-${MONO_VERSION} \
    mono-winforms-${MONO_VERSION} \
    mono-winfx-${MONO_VERSION} \
    mono-locale-extras-${MONO_VERSION} \
    mono-devel-${MONO_VERSION} \
    mono-web-devel-${MONO_VERSION} \
    gtk-sharp2-${GTKSHARP_VERSION} \
    gtk-sharp2-devel-${GTKSHARP_VERSION} \
    msbuild-${MSBUILD_VERSION} \
    msbuild-sdkresolver-${MSBUILD_VERSION} \
    msbuild-libhostfxr \
    xmlstarlet
RUN microdnf --enablerepo=\* clean all

CMD ["/bin/bash"]
