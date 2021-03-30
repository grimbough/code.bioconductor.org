FROM alpine:3.13.2 AS zoekt-webserver
LABEL maintainer "Mike Smith <mike.smith@embl.de>"

# We need go, git, bash, and musl-dev for zoekt-git-index
RUN apk add --no-cache go git 

RUN go get -u golang.org/x/sys/... \
    golang.org/x/sync/semaphore \
    github.com/fsnotify/fsnotify \
    go.uber.org/automaxprocs \
    github.com/prometheus/client_golang/prometheus \
    github.com/google/zoekt/

RUN go install github.com/google/zoekt/cmd/zoekt-webserver



FROM alpine:3.13.2

COPY --from=zoekt-webserver /root/go/bin/* /usr/local/bin/

RUN adduser --disabled-password --uid 82 www-data
USER www-data

ADD ./templates /var/templates

EXPOSE 8080

ENTRYPOINT ["zoekt-webserver", "-listen", ":8080", "-index", "/var/zoekt", "-template_dir", "/var/templates"]