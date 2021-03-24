FROM alpine:latest
LABEL maintainer "Mike Smith <mike.smith@embl.de>"


# We need go, git, bash, and musl-dev for zoekt-git-index
RUN apk add --no-cache go git musl-dev bash

RUN go get -u golang.org/x/sys/...
RUN go get -u golang.org/x/sync/semaphore 
RUN go get -u github.com/fsnotify/fsnotify
RUN go get github.com/prometheus/client_golang/prometheus
RUN go get -u go.uber.org/automaxprocs

RUN go get github.com/google/zoekt/

RUN go install github.com/google/zoekt/cmd/zoekt-webserver

RUN mkdir /var/zoekt

WORKDIR /root

ADD ./templates /root/templates

EXPOSE 6070

ENTRYPOINT ["/root/go/bin/zoekt-webserver", "-listen", ":6070", "-index", "/var/zoekt", "-template_dir", "/root/templates"]

#RUN bash

