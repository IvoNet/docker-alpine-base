FROM alpine:3.15.4
LABEL maintainer="@IvoNet"

# set version for s6 overlay
ARG OVERLAY_VERSION="v3.1.0.1"

RUN apk --no-cache --no-progress add bash curl tar xz \
 && curl -s -L "https://github.com/just-containers/s6-overlay/releases/download/v3.1.0.1/s6-overlay-noarch.tar.xz" -o /tmp/s6-overlay-noarch.tar.xz \
 && tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz \
 && curl -s -L "https://github.com/just-containers/s6-overlay/releases/download/v3.1.0.1/s6-overlay-$(uname -m).tar.xz" -o /tmp/s6-overlay-$(uname -m).tar.xz \
 && tar -C / -Jxpf /tmp/s6-overlay-$(uname -m).tar.xz \
 && apk del --purge tar xz \
 && rm -rfv /tmp/* \

# environment variables
ENV PS1="$(whoami):$(pwd)\\$ " \
    HOME="/root" \
    TERM="xterm"

COPY root/ /

RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache --virtual=build-dependencies \
	curl \
	patch \
	tar \
    xz && \
 echo "**** install runtime packages ****" && \
 apk add --no-cache \
	bash \
	ca-certificates \
	coreutils \
	procps \
	shadow \
	tzdata && \
 echo "**** create abc user and make our folders ****" && \
 groupmod -g 1000 users && \
 useradd -u 911 -U -d /config -s /bin/false abc && \
 usermod -G users abc && \
 mkdir -p \
	/app \
	/config \
	/defaults && \
 echo "**** cleanup ****" && \
 apk del --purge build-dependencies && \
 chmod +x /etc/cont-init.d/* && \
 rm -rf \
	/tmp/*




ENTRYPOINT ["/init"]
