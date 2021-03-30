FROM alpine:3.13.2 AS zoekt-index

RUN apk --no-cache add go git

ENV CGO_ENABLED=0

RUN go get -u golang.org/x/sys/... \
    golang.org/x/sync/semaphore \
    github.com/fsnotify/fsnotify \
    go.uber.org/automaxprocs \
    github.com/prometheus/client_golang/prometheus \
    github.com/google/zoekt/

RUN go install github.com/google/zoekt/cmd/zoekt-index



FROM alpine:3.13.2 AS ctags

RUN apk --no-cache add wget

ENV CTAGS_BIN ctags-2020-08-26T1308-c9ebd839

RUN wget https://storage.googleapis.com/zoekt-binaries/${CTAGS_BIN}.tar.gz && \
    tar -xvzf ${CTAGS_BIN}.tar.gz && \
    mv ${CTAGS_BIN} ctags && \
    chmod +rx ctags/*



FROM alpine:3.13.2
LABEL maintainer "Mike Smith <mike.smith@embl.de>"

COPY --from=ctags /ctags/* /usr/local/bin/
COPY --from=zoekt-index /root/go/bin/* /usr/local/bin/

RUN adduser --disabled-password --uid 82 www-data
USER www-data

COPY create_zoekt_index.sh /usr/local/bin/create_zoekt_index

ENTRYPOINT ["create_zoekt_index"]
