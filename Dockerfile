FROM alpine:edge
MAINTAINER Maxime FRANCK

ENV S6_OVERLAY_VERSION=v1.18.1.5
ENV  GODNSMASQ_VERSION=1.0.7
ENV TMP_BUILD_DIR /tmp/build

ADD root /
ADD https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-nobin.tar.gz ${TMP_BUILD_DIR}/
ADD https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-nobin.tar.gz.sig ${TMP_BUILD_DIR}/
ADD https://github.com/janeczku/go-dnsmasq/releases/download/${GODNSMASQ_VERSION}/go-dnsmasq-min_linux-amd64 /bin/go-dnsmasq

COPY keys/trust.gpg ${TMP_BUILD_DIR}/

RUN addgroup -g 1000 app && \
    adduser -D  -G app -s /bin/false -u 1000 app  && \
    apk add --no-cache s6 s6-portable-utils bind-tools && \
    apk add --no-cache --virtual build libcap gnupg && \
    cd ${TMP_BUILD_DIR} && \
    gpg --no-default-keyring --keyring ./trust.gpg s6-overlay-nobin.tar.gz.sig && \
    tar -C / -xf s6-overlay-nobin.tar.gz && \
    cd / && \
    rm -rf ${TMP_BUILD_DIR} &&\
    chmod +x /bin/go-dnsmasq && \
    addgroup go-dnsmasq && \
    adduser -D -g "" -s /bin/sh -G go-dnsmasq go-dnsmasq && \
    setcap CAP_NET_BIND_SERVICE=+eip /bin/go-dnsmasq && \
    apk del build

ENTRYPOINT ["/init"]
