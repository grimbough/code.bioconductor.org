FROM alpine:3.13 AS zoekt-index

RUN apk --no-cache add go git

ENV CGO_ENABLED=0

RUN go get -u golang.org/x/sys/... \
    golang.org/x/sync/semaphore \
    github.com/fsnotify/fsnotify \
    go.uber.org/automaxprocs \
    github.com/prometheus/client_golang/prometheus \
    github.com/google/zoekt/

RUN go install github.com/google/zoekt/cmd/zoekt-index



FROM alpine:3.13
LABEL maintainer "Mike Smith <mike.smith@embl.de>"

COPY --from=zoekt-index /root/go/bin/* /usr/local/bin/

RUN adduser --disabled-password --uid 82 www-data
USER www-data

COPY create_zoekt_index.sh /usr/local/bin/create_zoekt_index

ENTRYPOINT ["create_zoekt_index"]
