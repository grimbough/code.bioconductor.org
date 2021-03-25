FROM alpine:3.13.2
LABEL maintainer "Mike Smith <mike.smith@embl.de>"

# We need go, git, bash, and musl-dev for zoekt-git-index
RUN apk add --no-cache go git bash

RUN go get -u golang.org/x/sys/... \
    golang.org/x/sync/semaphore \
    github.com/fsnotify/fsnotify \
    go.uber.org/automaxprocs \
    github.com/prometheus/client_golang/prometheus \
    github.com/google/zoekt/

RUN go install github.com/google/zoekt/cmd/zoekt-webserver

RUN mkdir /var/zoekt

WORKDIR /root

ADD ./templates /root/templates

EXPOSE 6070

ENTRYPOINT ["/root/go/bin/zoekt-webserver", "-listen", ":6070", "-index", "/var/zoekt", "-template_dir", "/root/templates"]


