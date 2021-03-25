FROM alpine:3.13.2
LABEL maintainer "Mike Smith <mike.smith@embl.de>"

# We need go, git, bash, and musl-dev for zoekt-git-index
RUN apk add --no-cache go git musl-dev bash

RUN go get -u golang.org/x/sys/... \
    golang.org/x/sync/semaphore \
    github.com/fsnotify/fsnotify \
    go.uber.org/automaxprocs \
    github.com/prometheus/client_golang/prometheus \
    github.com/google/zoekt/

RUN go get github.com/google/zoekt/

RUN go install github.com/google/zoekt/cmd/zoekt-index

RUN mkdir $HOME/zoekt $HOME/repositories

COPY ./create_zoekt_index.sh .

ENTRYPOINT ["./create_zoekt_index.sh"]

