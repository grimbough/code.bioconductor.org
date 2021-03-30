FROM alpine:3.11 AS ctags
LABEL maintainer "Mike Smith <mike.smith@embl.de>"

RUN apk --no-cache add --virtual build-deps ca-certificates curl jansson-dev \
    libseccomp-dev linux-headers autoconf pkgconfig make automake \
    gcc g++ binutils

ENV CTAGS_VERSION=03f933a96d3ef87adbf9d167462d45ce69577edb

RUN curl -fsSL -o ctags.tar.gz "https://codeload.github.com/universal-ctags/ctags/tar.gz/$CTAGS_VERSION" && \
    tar -C /tmp -xzf ctags.tar.gz && cd /tmp/ctags-$CTAGS_VERSION && \
    ./autogen.sh && LDFLAGS=-static ./configure --program-prefix=universal- --enable-json --enable-seccomp && \
    make -j2 && make install && cd && \
    rm -rf /tmp/ctags-$CTAGS_VERSION && \
    apk --no-cache --purge del build-deps

FROM alpine:3.11 AS zoekt-index

RUN apk --no-cache add go git

RUN go get -u golang.org/x/sys/... \
    golang.org/x/sync/semaphore \
    github.com/fsnotify/fsnotify \
    go.uber.org/automaxprocs \
    github.com/prometheus/client_golang/prometheus \
    github.com/google/zoekt/

RUN go install github.com/google/zoekt/cmd/zoekt-index




FROM alpine:3.11

COPY --from=ctags /usr/local/bin/universal-* /usr/local/bin/
COPY --from=zoekt-index /root/go/bin/* /usr/local/bin/

RUN adduser --disabled-password --uid 82 www-data
USER www-data

COPY ./create_zoekt_index.sh /usr/local/bin/

ENTRYPOINT ["create_zoekt_index.sh"]
